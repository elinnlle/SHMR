//
//  BankAccount.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

struct BankAccount: Identifiable {
    let id: Int
    let userId: Int
    var name: String
    var balance: Decimal
    let currency: String
    let createdAt: Date
    var updatedAt: Date
}
