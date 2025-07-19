//
//  StoresFactory.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

@MainActor
struct StoresFactory {
    static var shared = StoresFactory()

    private var method: PersistenceMethod {
        UserDefaults.standard.storageMethod
    }

    func transactions() -> TransactionsStore {
        switch method {
        case .swiftData: SwiftDataTransactionsStore()
        case .coreData:  CoreDataTransactionsStore()
        }
    }

    func accounts() -> BankAccountsStore {
        switch method {
        case .swiftData: SwiftDataBankAccountsStore()
        case .coreData:  CoreDataBankAccountsStore()
        }
    }

    func categories() -> CategoriesStore {
        switch method {
        case .swiftData: SwiftDataCategoriesStore()
        case .coreData:  CoreDataCategoriesStore()
        }
    }

    func backup() -> BackupStore {
        switch method {
        case .swiftData: SwiftDataBackupStore()
        case .coreData:  CoreDataBackupStore()
        }
    }
}
