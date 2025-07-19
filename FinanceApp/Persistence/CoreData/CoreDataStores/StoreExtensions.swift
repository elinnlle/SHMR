//
//  StoreExtensions.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 19.07.2025.
//

import Foundation

extension TransactionsStore {
    func deleteAll() throws {
        for tx in try all() {
            try delete(id: tx.id)
        }
    }
}

extension CategoriesStore {
    func deleteAll() throws {
        try replaceAll(with: [])
    }
}

extension BankAccountsStore {
    func deleteAll() throws {
        for acc in try all() {
            try delete(id: acc.id)
        }
    }
}

extension BackupStore {
    func deleteAll() throws {
        for item in try items() {
            try remove(id: item.id)
        }
    }
}
