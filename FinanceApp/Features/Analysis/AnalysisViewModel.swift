//
//  AnalysisViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 08.07.2025.
//

import Foundation
import Combine

@MainActor
final class AnalysisViewModel {

    // MARK: Published
    @Published private(set) var transactions:       [Transaction] = []
    @Published private(set) var sortedTransactions: [Transaction] = []
    @Published private(set) var total:              Decimal       = .zero

    // MARK: Private
    private var service: TransactionsServiceProtocol
    private let categoriesService: CategoriesServiceProtocol

    // MARK: Init
    init(
        service: TransactionsServiceProtocol?            = nil,
        categoriesService: CategoriesServiceProtocol?    = nil
    ) {
        self.service           = service           ?? TransactionsService()
        self.categoriesService = categoriesService ?? CategoriesService()
    }
    
    /// Словарь [categoryId: Category]
    private var categoryMap: [Int: Category] = [:]

    /// Возвращает имя категории по её id
    func categoryName(for categoryId: Int) -> String {
        return categoryMap[categoryId]?.name ?? "—"
    }
    
    // MARK: Public
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
            
            await MainActor.run {
                self.categoryMap = catMap
            }
                
            let filtered = all.filter { tx in
                guard let cat = catMap[tx.categoryId] else { return false }
                return cat.isIncome == (direction == .income)
            }
            let sum = filtered.reduce(.zero) { $0 + $1.amount }
                
            await MainActor.run {
                self.categoryMap = catMap
                self.transactions = filtered
                self.total        = sum
                self.applySort(option: sort)
            }
        } catch {
            print("Analysis load error:", error)
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
                start:     start,
                end:       end,
                sort:      sort,
                accountId: accountId
            )
        }
    }

    func applySort(option: SortOption) {
        sortedTransactions = transactions.sorted(by: option)
    }

    var totalFormatted: String {
        let nf = NumberFormatter()
        nf.locale         = Locale(identifier: "ru_RU")
        nf.numberStyle    = .currency
        nf.currencySymbol = "₽"
        let absTotal = total < 0 ? -total : total
        return nf.string(for: absTotal) ?? "\(absTotal) ₽"
    }
}
