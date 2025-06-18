//
//  TransactionsServiceMock.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

final class TransactionsServiceMock: TransactionsServiceProtocol {
    private let cache = TransactionsFileCache()

    func transactions(
        for accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        cache.transactions.filter {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    func create(_ tx: Transaction) async throws {
        cache.add(tx)
    }

    func update(_ tx: Transaction) async throws {
        cache.remove(id: tx.id)
        cache.add(tx)
    }

    func delete(id: Int) async throws {
        cache.remove(id: id)
    }
}
