//
//  HistoryViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    private let service: TransactionsServiceProtocol = TransactionsService()
    private let categoriesService: CategoriesServiceProtocol = CategoriesService()
    
    @Published private(set) var transactions:       [Transaction] = []
    @Published private(set) var sortedTransactions: [Transaction] = []
    @Published private(set) var total:              Decimal       = 0

    /// Загрузка и фильтрация транзакций
    func reload(
        direction: Direction,
        start: Date,
        end: Date,
        sort: SortOption,
        accountId: Int
    ) async throws {
        do {
            let all        = try await service.transactions(for: accountId, from: start, to: end)
            let categories = try await categoriesService.categories()
            let catMap     = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
            let filtered = all.filter { tx in
                guard let cat = catMap[tx.categoryId] else { return false }
                return cat.isIncome == (direction == .income)
            }
            let sum = filtered.reduce(.zero) { $0 + $1.amount }
                    
                self.transactions = filtered
                self.total        = sum
                self.applySort(option: sort)
        } catch let error as URLError where error.code == .cancelled {
        } catch {
            print("History load error:", error)
        }
    }
        
    func load(
        direction: Direction,
        start: Date,
        end: Date,
        sort: SortOption,
        accountId: Int
    ) {
        Task {
            try? await reload(
                direction: direction,
                start: start,
                end: end,
                sort: sort,
                accountId: accountId
            )
        }
    }

    /// Сортировка по выбранному опциону
    func applySort(option: SortOption) {
        sortedTransactions = transactions.sorted(by: option)
    }

    /// Форматирование общей суммы
    var totalFormatted: String {
        let nf = NumberFormatter()
        nf.numberStyle    = .currency
        nf.locale         = Locale(identifier: "ru_RU")
        nf.currencySymbol = "₽"
        let absTotal = total < 0 ? -total : total
        return nf.string(for: absTotal) ?? "\(absTotal) ₽"
    }
}
