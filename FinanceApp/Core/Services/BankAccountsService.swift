//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

@MainActor
final class BankAccountsService: BankAccountsServiceProtocol {

    private let client: NetworkClient
    private let store:  BankAccountsStore
    private let backup: BackupStore

    init(
        client: NetworkClient          = .init(),
        store:  BankAccountsStore?     = nil,
        backup: BackupStore?           = nil
    ) {
        self.client = client
        self.store  = store  ?? SwiftDataBankAccountsStore()
        self.backup = backup ?? SwiftDataBackupStore()
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }

    private func upsert(_ account: BankAccount) throws {
        if try store.account(id: account.id) != nil {
            try store.update(account)
        } else {
            try store.create(account)
        }
    }

    /// Пытаемся выгрузить очередь BackupStore на сервер
    private func uploadBackup() async {
        for item in (try? backup.items()) ?? [] {
            do {
                // В backup для аккаунтов храним только .update
                guard item.action == .update,
                      let data = item.payload else {
                    try? backup.remove(id: item.id)
                    continue
                }
                let acct = try decoder.decode(BankAccount.self, from: data)
                _ = try await update(account: acct)
                try? backup.remove(id: item.id)
            } catch {
                if let urlError = error as? URLError,
                   urlError.code == .badServerResponse {
                    // 404 — считаем удалённым на сервере
                    try? backup.remove(id: item.id)
                } else {
                    print("Permanent error for backup item account(\(item.id)): \(error)")
                }
            }
        }
    }

    func account() async throws -> BankAccount {
        // Синхронизируем бэкап
        await uploadBackup()

        // Смотрим на счёт в базе и в очереди
        do {
            let allLocal = try store.all()
            print("store.all(): \(allLocal.map(\.id))")
        } catch {
            print("store.all() failed:", error)
        }
        do {
            let items = try backup.items()
            print("backup.items(): \(items.map { "\($0.action)(\($0.id))" })")
        } catch {
            print("backup.items() failed:", error)
        }

        // Пытаемся получить свежий аккаунт
        do {
            let list: [BankAccount] = try await client.request(
                "accounts",
                method: .get,
                body: Optional<EmptyBody>.none
            )
            if let first = list.first {
                // 3a. Сохраняем серверную копию в стор
                try upsert(first)
            }
        } catch {
            print("Network fetch failed, using local copy: \(error)")
        }

        // Возвращаем всегда локальную копию
        let all = try store.all()
        if let local = all.first {
            return local
        } else {
            // если локально вообще ничего нет — сообщаем об ошибке
            throw NetworkError.noData
        }
    }

    func update(account: BankAccount) async throws -> BankAccount {
        let path = "accounts/\(account.id)"

        // Логируем запрос
        let data = try encoder.encode(account)
        if let json = String(data: data, encoding: .utf8) {
            print("PUT https://shmr-finance.ru/api/v1/\(path)\nBody: \(json)")
        }

        do {
            // Пробуем сеть
            let updated: BankAccount = try await client.request(
                path,
                method: .put,
                body: account
            )
            // Если успешно — кешируем в локальный стор и чистим бэкап
            try upsert(updated)
            try? backup.remove(id: updated.id)
            return updated
        } catch {
            // При провале — добавляем в бэкап
            try upsert(account)
            let payload = try encoder.encode(account)
            try? backup.upsert(.init(id: account.id, action: .update, payload: payload))
            throw error
        }
    }
}
