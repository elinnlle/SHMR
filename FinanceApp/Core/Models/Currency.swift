//
//  Currency.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation

struct Currency: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String

    static let rub: Currency = .init(code: "RUB", name: "Российский рубль", symbol: "₽")
    static let usd: Currency = .init(code: "USD", name: "Американский доллар", symbol: "$")
    static let eur: Currency = .init(code: "EUR", name: "Евро", symbol: "€")

    static let all: [Currency] = [.rub, .usd, .eur]
}
