//
//  TransactionsServiceMock.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

final class TransactionsServiceMock: TransactionsServiceProtocol {
    static let shared = TransactionsServiceMock()
         init() {}
    
    private var sample: [Transaction] = {
        let now = Date()
        let cal = Calendar.current
        
        // Расходы пример
        let expenses: [Transaction] = [
            .init(id:  1, accountId: 1, categoryId: 1,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour:  9, minute:  0,  second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  2, accountId: 1, categoryId: 2,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 10, minute: 15, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  3, accountId: 1, categoryId: 3,  amount: -100_000, comment: "Джек",
                  transactionDate: cal.date(bySettingHour: 11, minute: 30, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  4, accountId: 1, categoryId: 3,  amount: -100_000, comment: "Энни",
                  transactionDate: cal.date(bySettingHour: 12, minute: 45, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  5, accountId: 1, categoryId: 4,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 14, minute:  0,  second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  6, accountId: 1, categoryId: 5,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 15, minute: 15, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  7, accountId: 1, categoryId: 6,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 16, minute: 30, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  8, accountId: 1, categoryId: 7,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 17, minute: 45, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id:  9, accountId: 1, categoryId: 8,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 19, minute:  0,  second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id: 10, accountId: 1, categoryId: 9,  amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 20, minute: 15, second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id: 11, accountId: 1, categoryId: 10, amount: -100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 21, minute: 30, second: 0, of: now)!,
                  createdAt: now, updatedAt: now)
        ]

        // Доходы пример
        let incomes: [Transaction] = [
            .init(id: 21, accountId: 1, categoryId: 11, amount: 100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 10, minute:  0,  second: 0, of: now)!,
                  createdAt: now, updatedAt: now),
            .init(id: 22, accountId: 1, categoryId: 12, amount: 100_000, comment: nil,
                  transactionDate: cal.date(bySettingHour: 12, minute: 30, second: 0, of: now)!,
                  createdAt: now, updatedAt: now)
        ]

        return expenses + incomes
    }()

    // MARK: — Возвращаем примеры, отфильтрованные по дате
    func transactions(
            for accountId: Int,
            from startDate: Date,
            to endDate: Date
        ) async throws -> [Transaction] {
            sample.filter {
                $0.accountId == accountId &&
                $0.transactionDate >= startDate &&
                $0.transactionDate <= endDate
            }
        }

        func create(_ tx: Transaction) async throws {
            print("👉 create:", tx)
            sample.append(tx)
        }

        func update(_ tx: Transaction) async throws {
            print("👉 update:", tx)
            sample.removeAll { $0.id == tx.id }
            sample.append(tx)
        }

        func delete(id: Int) async throws {
            print("👉 delete id:", id)
            sample.removeAll { $0.id == id }
        }
}
