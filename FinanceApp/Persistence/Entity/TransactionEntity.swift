//
//  TransactionEntity.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import SwiftData
import Foundation

@Model final class TransactionEntity {
    @Attribute(.unique) var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date

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

    var model: Transaction {
        .init(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Быстрое создание из бизнес‑модели.
    convenience init(from tx: Transaction) {
        self.init(
            id: tx.id,
            accountId: tx.accountId,
            categoryId: tx.categoryId,
            amount: tx.amount,
            transactionDate: tx.transactionDate,
            comment: tx.comment,
            createdAt: tx.createdAt,
            updatedAt: tx.updatedAt
        )
    }
}
