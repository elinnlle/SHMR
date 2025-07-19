//
//  SortOption.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.07.2025.
//

import Foundation

enum SortOption: Int, CaseIterable {
    case date, amount
    var title: String {
        switch self {
        case .date:   return "По дате"
        case .amount: return "По сумме"
        }
    }
}

extension Array where Element == Transaction {
    func sorted(by option: SortOption) -> [Transaction] {
        switch option {
        case .date:
            return self.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return self.sorted {
                $0.amount.magnitude > $1.amount.magnitude
            }
        }
    }
}
