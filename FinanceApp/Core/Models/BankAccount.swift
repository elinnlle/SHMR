//
//  BankAccount.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

struct BankAccount: Identifiable, Codable {
    let id: Int
    let name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    let updatedAt: Date
    
    init(id: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, balance, currency, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = try c.decode(Int.self, forKey: .id)
        name     = try c.decode(String.self, forKey: .name)

        // баланс приходит строкой
        let balStr = try c.decode(String.self, forKey: .balance)
        guard let bal = Decimal(string: balStr) else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance,
                in: c,
                debugDescription: "Cannot convert \(balStr) to Decimal"
            )
        }
        balance = bal

        currency = try c.decode(String.self, forKey: .currency)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let createdStr = try c.decode(String.self, forKey: .createdAt)
        let updatedStr = try c.decode(String.self, forKey: .updatedAt)
        guard
            let created = iso.date(from: createdStr),
            let updated = iso.date(from: updatedStr)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: c,
                debugDescription: "Cannot parse dates"
            )
        }
        createdAt = created
        updatedAt = updated
    }
}
