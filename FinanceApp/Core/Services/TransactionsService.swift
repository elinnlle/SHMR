//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

@MainActor
final class TransactionsService: TransactionsServiceProtocol {

    private let client: NetworkClient
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    
    private let store: TransactionsStore
    private let backup: BackupStore
    private let bankService: BankAccountsServiceProtocol
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        client: NetworkClient = .init(),
        store: TransactionsStore? = nil,
        backup: BackupStore? = nil,
        bankService: BankAccountsServiceProtocol? = nil
    ) {
        self.client = client
        self.store = store ?? SwiftDataTransactionsStore()
        self.backup = backup ?? SwiftDataBackupStore()
        self.bankService = bankService ?? BankAccountsService()
        
    }

    private func upsert(_ tx: Transaction) throws {
        if try store.transaction(id: tx.id) != nil {
            try store.update(tx)
        } else {
            try store.create(tx)
        }
    }

    // Синхронизируем очередь backup: create/update/delete
    private func uploadBackup() async {
        for item in (try? backup.items()) ?? [] {
            do {
                switch item.action {
                case .create:
                    if let data = item.payload,
                       let txReq = try? decoder.decode(TransactionRequest.self, from: data) {
                        let _: Transaction = try await client.request(
                            "transactions",
                            method: .post,
                            body: txReq
                        )
                    }
                case .update:
                    if let data = item.payload,
                       let txReq = try? decoder.decode(TransactionRequest.self, from: data) {
                        let path = "transactions/\(item.id)"
                        let _: Transaction = try await client.request(
                            path,
                            method: .put,
                            body: txReq
                        )
                    }
                case .delete:
                    let path = "transactions/\(item.id)"
                    let _: EmptyResponse = try await client.request(
                        path,
                        method: .delete,
                        body: Optional<EmptyBody>.none
                    )
                }
                try? backup.remove(id: item.id)
            } catch {
                print("Permanent error for backup item transaction(\(item.id)): \(error)")
            }
        }
    }

    func transactions(
        for accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        // Синхронизируем бэкап
        await uploadBackup()

        // Отладочные логи
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

        // Формируем URL
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)

        let startStr = df.string(from: startDate)
        let endStr   = df.string(from: endDate)

        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = "shmr-finance.ru"
        comps.path   = "/api/v1/transactions/account/\(accountId)/period"
        comps.queryItems = [
            URLQueryItem(name: "startDate", value: startStr),
            URLQueryItem(name: "endDate",   value: endStr)
        ]

        guard let url = comps.url else {
            throw URLError(.badURL)
        }
        let relativePath = url.absoluteString
            .replacingOccurrences(of: "https://shmr-finance.ru/api/v1/", with: "")

        // Пробуем сеть и апдейтим локальный стор
        do {
            let remote: [Transaction] = try await client.request(
                relativePath,
                method: .get,
                body: Optional<EmptyBody>.none
            )
            // Если успешно — сохраняем/обновляем каждую транзакцию локально
            for tx in remote {
                try upsert(tx)
            }
        } catch {
            print("Network fetch failed, using local copy: \(error)")
        }

        // 5. Всегда возвращаем локальную копию (с учётом бэкапа)
        let local   = (try? store.all()) ?? []
        let backupTxs: [Transaction] = (try? backup.items())?.compactMap { item in
            guard let data = item.payload else { return nil }
            return try? decoder.decode(Transaction.self, from: data)
        } ?? []

        let merged = Dictionary(
            uniqueKeysWithValues: (local + backupTxs).map { ($0.id, $0) }
        )
        .values
        
        let filteredByDate = merged.filter { tx in
            tx.transactionDate >= startDate && tx.transactionDate <= endDate
        }

        return Array(filteredByDate)
    }

    func create(_ tx: Transaction) async {
        await uploadBackup()
        
        let absAmount = tx.amount < 0
            ? tx.amount.magnitude.description
            : tx.amount.description
        let req = TransactionRequest(
            accountId: tx.accountId,
            categoryId: tx.categoryId,
            amount: absAmount,
            transactionDate: isoFormatter.string(from: tx.transactionDate),
            comment: tx.comment ?? ""
        )

        do {
            let created: Transaction = try await client.request(
                "transactions",
                method: .post,
                body: req
            )
            print("Response (201): \(created)")
            try upsert(created)
        } catch {
            // оффлайн / SSL / любая другая ошибка
            print("⚠️ Network error on create, saving locally and to backup:", error)
            do {
                try upsert(tx)
                let payload = try JSONEncoder().encode(req)
                try backup.upsert(.init(
                    id: tx.id,
                    action: .create,
                    payload: payload
                ))
            } catch {
                print("❌ Failed to save backup item:", error)
            }
            do {
                var account = try await bankService.account()
                account.balance += tx.amount
                _ = try await bankService.update(account: account)
            } catch {
                print("❌ Failed to save account backup:", error)
            }
        }
        await uploadBackup()
    }

    func update(_ tx: Transaction) async {
        await uploadBackup()
        
        let req = TransactionRequest(
            accountId: tx.accountId,
            categoryId: tx.categoryId,
            amount: tx.amount.description,
            transactionDate: isoFormatter.string(from: tx.transactionDate),
            comment: tx.comment
        )
        do {
            let updated: Transaction = try await client.request(
                "transactions/\(tx.id)",
                method: .put,
                body: req
            )
            try upsert(updated)
        } catch {
            print("⚠️ Network error on update, saving locally and to backup:", error)
            do {
                try upsert(tx)
                let payload = try JSONEncoder().encode(req)
                try backup.upsert(.init(
                    id: tx.id,
                    action: .update,
                    payload: payload
                ))
            } catch {
                print("❌ Failed to save backup item:", error)
            }
            do {
                var account = try await bankService.account()
                account.balance += tx.amount
                _ = try await bankService.update(account: account)
            } catch {
                print("❌ Failed to save account backup:", error)
            }
        }
    }

    func delete(id: Int) async throws {
        // Синхронизируем старые бэкапы
        await uploadBackup()

        // Получаем транзакцию, чтобы знать сумму
        let txToDelete: Transaction?
        do {
            txToDelete = try store.transaction(id: id)
        } catch {
            txToDelete = nil
            print("Failed to fetch tx(\(id)) before delete:", error)
        }

        // 3. Удаляем саму транзакцию локально
        do {
            try store.delete(id: id)
        } catch {
            print("Local delete error for tx(\(id)):", error)
        }

        // Откатываем баланс
        if let tx = txToDelete {
            do {
                var account = try await bankService.account()
                account.balance -= tx.amount
                _ = try await bankService.update(account: account)
            } catch {
                print("Error updating account after tx delete:", error)
            }
        }

        let path = "transactions/\(id)"
        print("DELETE https://shmr-finance.ru/api/v1/\(path)")
        do {
            let _: EmptyResponse = try await client.request(
                path,
                method: .delete,
                body: Optional<EmptyBody>.none
            )
        } catch {
            print("Backup delete queued for tx(\(id)):", error)
        }
    }

}
