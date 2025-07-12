//
//  Transaction+Foundation.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard
            let dict       = jsonObject as? [String: Any],
            let id         = dict["id"]           as? Int,
            let accId      = dict["accountId"]    as? Int,
            let catId      = dict["categoryId"]   as? Int,
            let amountStr  = dict["amount"]       as? String,
            let txDateStr  = dict["transactionDate"] as? String,
            let createdStr = dict["createdAt"]  as? String,
            let updatedStr = dict["updatedAt"]  as? String
        else {
            return nil
        }

        guard let decAmount = Decimal(string: amountStr) else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard
            let txDate  = iso.date(from: txDateStr),
            let created = iso.date(from: createdStr),
            let updated = iso.date(from: updatedStr)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            accountId: accId,
            categoryId: catId,
            amount: decAmount,
            comment: comment,
            transactionDate: txDate,
            createdAt: created,
            updatedAt: updated
        )
    }

    var jsonObject: Any {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [
            "id":              id,
            "accountId":       accountId,
            "categoryId":      categoryId,
            "amount":          amount.description,
            "transactionDate": iso.string(from: transactionDate),
            "comment":         comment as Any,
            "createdAt":       iso.string(from: createdAt),
            "updatedAt":       iso.string(from: updatedAt)
        ]
    }
}
