//
//  BankAccountsServiceProtocol.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func account() async throws -> BankAccount
    func update(account: BankAccount) async throws -> BankAccount
}
