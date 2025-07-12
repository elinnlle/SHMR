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
    private var service: TransactionsServiceProtocol = TransactionsServiceMock.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init
    init(service: TransactionsServiceProtocol = TransactionsServiceMock.shared) {
        self.service = service
    }

    // MARK: Public
    func load(
        direction: Direction,
        start: Date,
        end: Date,
        sort: SortOption
    ) {
        Task {
            do {
                let all = try await service.transactions(for: 1, from: start, to: end)
                let filtered = all.filter { $0.deducedDirection == direction }
                let sum      = filtered.reduce(.zero) { $0 + $1.amount }

                await MainActor.run {
                    self.transactions = filtered
                    self.total        = sum
                    self.applySort(option: sort)
                }
            } catch {
                print("Analysis load error:", error)
            }
        }
    }

    func applySort(option: SortOption) {
        switch option {
        case .date:
            sortedTransactions = transactions
                .sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            sortedTransactions = transactions
                .sorted { $0.amount > $1.amount }
        }
    }

    var totalFormatted: String {
        let nf = NumberFormatter()
        nf.locale         = Locale(identifier: "ru_RU")
        nf.numberStyle    = .currency
        nf.currencySymbol = "₽"
        let absTotal = total < 0 ? -total : total
        return nf.string(for: absTotal) ?? "\(absTotal) ₽"
    }

    enum SortOption: Int, CaseIterable {
        case date, amount
        var title: String {
            switch self {
            case .date:   return "По дате"
            case .amount: return "По сумме"
            }
        }
    }
}
