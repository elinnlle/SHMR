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
    private let service: TransactionsServiceProtocol = TransactionsServiceMock.shared
    
    @Published private(set) var transactions:       [Transaction] = []
    @Published private(set) var sortedTransactions: [Transaction] = []
    @Published private(set) var total:              Decimal       = 0

    /// Загрузка и фильтрация транзакций
    func load(
        direction: Direction,
        start: Date,
        end: Date,
        sort: SortOption
    ) {
        Task {
            do {
                let all = try await service.transactions(
                    for: 1,
                    from: start,
                    to:   end
                )
                let filtered = all.filter { $0.deducedDirection == direction }
                let sum      = filtered.reduce(.zero) { $0 + $1.amount }
                await MainActor.run {
                    self.transactions = filtered
                    self.total        = sum
                    self.applySort(option: sort)
                }
            } catch {
                print("History load error:", error)
            }
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
