//
//  TransactionsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

@MainActor
protocol TransactionsStore {
    /// Возвращает все транзакции.
    func all() throws -> [Transaction]

    /// Находит транзакцию по идентификатору.
    func transaction(id: Int) throws -> Transaction?

    /// Создаёт новую транзакцию.
    func create(_ tx: Transaction) throws

    /// Обновляет существующую транзакцию.
    func update(_ tx: Transaction) throws

    /// Удаляет транзакцию по идентификатору.
    func delete(id: Int) throws
}
