//
//  Transaction+Formatting.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import Foundation

extension Transaction {
    var formattedAmount: String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ru_RU")
        nf.numberStyle = .currency
        let value = amount < 0 ? -amount : amount
        return nf.string(for: value) ?? "\(value) ₽"
    }

    var deducedDirection: Direction {
        amount >= 0 ? .income : .outcome
    }
}
