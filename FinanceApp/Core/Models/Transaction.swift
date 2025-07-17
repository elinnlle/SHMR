//
//  Transaction.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

struct Transaction: Identifiable, Hashable, Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case account
        case category
        case accountId
        case categoryId
        case transactionDate, amount, comment, createdAt, updatedAt
    }
    private enum AccountKeys: String, CodingKey {
        case id, name, balance, currency
    }
    private enum CategoryKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }

    init(
        id: Int,
        accountId: Int,
        categoryId: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let acctCont = try? c.nestedContainer(keyedBy: AccountKeys.self, forKey: .account) {
            accountId = try acctCont.decode(Int.self, forKey: .id)
        } else {
            accountId = try c.decode(Int.self, forKey: .accountId)
        }

        if let catCont = try? c.nestedContainer(keyedBy: CategoryKeys.self, forKey: .category) {
            categoryId = try catCont.decode(Int.self, forKey: .id)
        } else {
            categoryId = try c.decode(Int.self, forKey: .categoryId)
        }

        id = try c.decode(Int.self, forKey: .id)

        let amountString = try c.decode(String.self, forKey: .amount)
        guard let decimal = Decimal(string: amountString) else {
          throw DecodingError.dataCorruptedError(
            forKey: .amount, in: c,
            debugDescription: "Bad amount string: \(amountString)")
        }
        amount = decimal

        // Декодируем даты напрямую
        transactionDate = try c.decode(Date.self, forKey: .transactionDate)
        createdAt       = try c.decode(Date.self, forKey: .createdAt)
        updatedAt       = try c.decode(Date.self, forKey: .updatedAt)

        // comment может быть null
        comment = try c.decodeIfPresent(String.self, forKey: .comment)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        
        try c.encode(id, forKey: .id)
        var acctCont = c.nestedContainer(keyedBy: AccountKeys.self, forKey: .account)
        try acctCont.encode(accountId, forKey: .id)
        var catCont = c.nestedContainer(keyedBy: CategoryKeys.self, forKey: .category)
        try catCont.encode(categoryId, forKey: .id)

        try c.encode(amount.description, forKey: .amount)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso.timeZone = TimeZone(secondsFromGMT: 0)

        try c.encode(iso.string(from: transactionDate), forKey: .transactionDate)
        try c.encodeIfPresent(comment, forKey: .comment)
        try c.encode(iso.string(from: createdAt), forKey: .createdAt)
        try c.encode(iso.string(from: updatedAt), forKey: .updatedAt)
    }
}
