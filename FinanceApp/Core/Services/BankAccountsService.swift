//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

final class BankAccountsService: BankAccountsServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    func account() async throws -> BankAccount {
        if let list: [BankAccount] = try? await client.request(
            "accounts",
            method: .get,
            body: Optional<EmptyBody>.none
        ) {
            guard let first = list.first else {
                throw NetworkError.noData
            }
            return first
        }
        return try await client.request(
            "accounts",
            method: .get,
            body: Optional<EmptyBody>.none
        )
    }

    func update(account: BankAccount) async throws -> BankAccount {
            let path = "accounts/\(account.id)"
            // Логируем запрос
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(account)
            if let json = String(data: data, encoding: .utf8) {
                print("PUT https://shmr-finance.ru/api/v1/\(path)\nBody: \(json)")
            }

            // Выполняем запрос и получаем обновленный счёт
            let updated: BankAccount = try await client.request(
                path,
                method: .put,
                body: account
            )

            // Логируем ответ
            print("Response (200): \(updated)")
            return updated
        }
}
