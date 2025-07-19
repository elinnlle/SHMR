//
//  BankAccountEntity.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var model: BankAccount {
        .init(
            id: id,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    convenience init(from account: BankAccount) {
        self.init(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
            createdAt: account.createdAt,
            updatedAt: account.updatedAt
        )
    }
}
