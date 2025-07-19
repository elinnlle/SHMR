//
//  TransactionsListViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation
import Combine

@MainActor
final class TransactionsListViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var total: Decimal = 0

    private let service: TransactionsServiceProtocol = TransactionsService()
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    private let accountsService: BankAccountsServiceProtocol = BankAccountsService()
    
    func reload(direction: Direction, accountId: Int) async throws {
        let today   = Date()
        let start   = today.startOfDay
        let end     = today.endOfDay

        let fetched   = try await service.transactions(for: accountId, from: start, to: end)
        let categories   = try await categoriesService.categories()
        let categoryMap  = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        
        let filtered = fetched.filter { tx in
            guard let cat = categoryMap[tx.categoryId] else { return false }
            return cat.isIncome == (direction == .income)
        }
        let sum = filtered
            .map { $0.amount.magnitude }
            .reduce(Decimal.zero, +)
        self.total = sum

        self.transactions = filtered
        self.total        = sum
    }

    func load(direction: Direction, accountId: Int) {
        Task {
            try? await reload(direction: direction, accountId: accountId)
        }
    }

    // MARK: – Форматирование суммы
    var totalFormatted: String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ru_RU")
        nf.numberStyle = .currency
        let absTotal = total < 0 ? -total : total
        return nf.string(for: absTotal) ?? "\(absTotal) ₽"
    }
}
