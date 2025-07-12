//
//  TransactionsServiceMock.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

actor TransactionsServiceMock: TransactionsServiceProtocol {

    static let shared = TransactionsServiceMock()

    private let cache = TransactionsFileCache()
    private let fileURL: URL

    private init(fileName: String = "transactions.json") {
        // путь в Documents
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.fileURL = docs.appendingPathComponent(fileName)

        do { try cache.load(from: fileURL) }
        catch { print("⚠️ TransactionsServiceMock.load failed:", error) }

        // три тестовые транзакции:
        if cache.transactions.isEmpty {
            let now = Date()
            let cal = Calendar.current

            let samples = [
                Transaction(
                  id: 1,
                  accountId: 1,
                  categoryId: 2,
                  amount: Decimal(-1500),
                  comment: "☕️ Кофе вчера",
                  transactionDate: cal.date(byAdding: .day,    value: -1, to: now)!,
                  createdAt: now, updatedAt: now
                ),
                Transaction(
                  id: 2,
                  accountId: 1,
                  categoryId: 3,
                  amount: Decimal(-3000),
                  comment: "🛒 Продукты сегодня",
                  transactionDate: cal.date(byAdding: .hour,   value: -3, to: now)!,
                  createdAt: now, updatedAt: now
                ),
                Transaction(
                  id: 3,
                  accountId: 1,
                  categoryId: 11,
                  amount: Decimal(50000),
                  comment: "💰 Зарплата",
                  transactionDate: cal.date(byAdding: .day,    value: -7, to: now)!,
                  createdAt: now, updatedAt: now
                )
            ]

            samples.forEach { cache.add($0) }
            try? cache.save(to: fileURL)
        }
    }

    func transactions(
      for accountId: Int,
      from startDate: Date,
      to   endDate:   Date
    ) async throws -> [Transaction] {
        cache.transactions
            .filter { $0.accountId       == accountId &&
                      $0.transactionDate >= startDate &&
                      $0.transactionDate <= endDate }
            .sorted { $0.transactionDate > $1.transactionDate }
    }

    func create(_ tx: Transaction) async throws {
        cache.add(tx)
        try cache.save(to: fileURL)
    }

    func update(_ tx: Transaction) async throws {
        cache.remove(id: tx.id)
        cache.add(tx)
        try cache.save(to: fileURL)
    }

    func delete(id: Int) async throws {
        cache.remove(id: id)
        try cache.save(to: fileURL)
    }
}
