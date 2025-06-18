//
//  BankAccountsServiceMock.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

final class BankAccountsServiceMock: BankAccountsServiceProtocol {
    private var stored = BankAccount(
        id:        .init(),
        userId:    .init(),
        name:      "Главный счёт",
        balance:   Decimal(100_000),
        currency:  "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )

    func account() async throws -> BankAccount {
        return stored
    }

    func update(account: BankAccount) async throws -> BankAccount {
        stored = account
        return stored
    }
}
