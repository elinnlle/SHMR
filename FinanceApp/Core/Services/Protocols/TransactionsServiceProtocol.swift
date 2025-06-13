//
//  TransactionsServiceProtocol.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    // Получить все транзакции по счёту за период
    func transactions(
        for accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction]

    // Создать новую транзакцию
    func create(_ tx: Transaction) async throws

    // Обновить транзакцию
    func update(_ tx: Transaction) async throws

    // Удалить транзакцию по ID
    func delete(id: Int) async throws
}
