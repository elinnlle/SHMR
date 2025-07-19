//
//  Services+DI.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

// MARK: – BankAccountsService DI
extension BankAccountsService {
    convenience init() {
        self.init(
            store:  StoresFactory.shared.accounts(),
            backup: StoresFactory.shared.backup()
        )
    }
}

// MARK: – CategoriesService DI
extension CategoriesService {
    convenience init() {
        self.init(
            store:  StoresFactory.shared.categories()
        )
    }
}

// MARK: – TransactionsService DI
extension TransactionsService {
    convenience init() {
        let accountsService = BankAccountsService()
        self.init(
            store:       StoresFactory.shared.transactions(),
            backup:      StoresFactory.shared.backup(),
            bankService: accountsService
        )
    }
}
