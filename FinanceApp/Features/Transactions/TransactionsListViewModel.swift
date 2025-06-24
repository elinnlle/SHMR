//
//  TransactionsListViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation
import Combine

final class TransactionsListViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var total: Decimal = 0

    private let service: TransactionsServiceProtocol = TransactionsServiceMock()
    
    func load(direction: Direction) {
        Task {
            do {
                let today = Date()
                let start = today.startOfDay
                let end = today.endOfDay
                let fetched = try await service.transactions(for: 1, from: start, to: end)
                let filtered = fetched.filter { $0.deducedDirection == direction }
                let sum = filtered.reduce(Decimal.zero) { $0 + $1.amount }
                await MainActor.run {
                    self.transactions = filtered
                    self.total = sum
                }
            } catch {
                print("Failed to load transactions: \(error)")
            }
        }
    }

    var totalFormatted: String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ru_RU")
        nf.numberStyle = .currency
        return nf.string(for: total) ?? "\(total) ₽"
    }
}
