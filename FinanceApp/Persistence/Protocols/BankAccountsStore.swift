//
//  BankAccountsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

@MainActor
protocol BankAccountsStore {
    /// Возвращает все счета.
    func all() throws -> [BankAccount]

    /// Находит счёт по идентификатору.
    func account(id: Int) throws -> BankAccount?

    /// Создаёт новый счёт.
    func create(_ account: BankAccount) throws

    /// Обновляет существующий счёт.
    func update(_ account: BankAccount) throws

    /// Удаляет счёт по идентификатору.
    func delete(id: Int) throws
}
