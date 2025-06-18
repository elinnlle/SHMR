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
    let comment: String?
    let transactionDate: Date
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id, accountId, categoryId, amount,
             transactionDate, comment, createdAt, updatedAt
    }

    init(
        id: Int,
        accountId: Int,
        categoryId: Int,
        amount: Decimal,
        comment: String?,
        transactionDate: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.comment = comment
        self.transactionDate = transactionDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(Int.self, forKey: .id)
        accountId       = try c.decode(Int.self, forKey: .accountId)
        categoryId      = try c.decode(Int.self, forKey: .categoryId)

        // amount приходит строкой
        let amountString = try c.decode(String.self, forKey: .amount)
        guard let decimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount,
                in: c,
                debugDescription: "Cannot parse Decimal from \(amountString)")
        }
        amount = decimal

        // даты приходят ISO-8601 строками
        let txDateString  = try c.decode(String.self, forKey: .transactionDate)
        let createdString = try c.decode(String.self, forKey: .createdAt)
        let updatedString = try c.decode(String.self, forKey: .updatedAt)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard
            let txDate = iso.date(from: txDateString),
            let created = iso.date(from: createdString),
            let updated = iso.date(from: updatedString)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .transactionDate,
                in: c,
                debugDescription: "Cannot parse dates from strings")
        }

        transactionDate = txDate
        createdAt       = created
        updatedAt       = updated

        comment = try c.decodeIfPresent(String.self, forKey: .comment)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,          forKey: .id)
        try c.encode(accountId,   forKey: .accountId)
        try c.encode(categoryId,  forKey: .categoryId)
        try c.encode(amount.description, forKey: .amount)

        // даты → ISO-8601 строки
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try c.encode(iso.string(from: transactionDate), forKey: .transactionDate)
        try c.encodeIfPresent(comment, forKey: .comment)
        try c.encode(iso.string(from: createdAt), forKey: .createdAt)
        try c.encode(iso.string(from: updatedAt), forKey: .updatedAt)
    }
}
