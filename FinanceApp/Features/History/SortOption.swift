//
//  SortOption.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.07.2025.
//

enum SortOption: Int, CaseIterable {
    case date, amount
    var title: String {
        switch self {
        case .date:   return "По дате"
        case .amount: return "По сумме"
        }
    }
}
