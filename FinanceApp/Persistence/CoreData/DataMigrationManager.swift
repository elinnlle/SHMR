//
//  DataMigrationManager.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

@MainActor
enum DataMigrationManager {
    static func migrateIfNeeded() async throws {
        let defaults = UserDefaults.standard
        let current  = defaults.storageMethod
        let last     = PersistenceMethod(rawValue: defaults.string(forKey: "last_storage_method") ?? "") ?? current

        // ничего не делаем, если способ не поменялся
        guard current != last else { return }

        print("⚙️  Migrating \(last) → \(current)")

        let oldFactory = StoresFactory.shared

        defaults.storageMethod = current
        let newFactory = StoresFactory.shared

        // Transactions
        let txs = try oldFactory.transactions().all()
        for tx in txs {
            try newFactory.transactions().create(tx)
        }
        try oldFactory.transactions().deleteAll()

        // Categories
        let cats = try oldFactory.categories().all()
        try newFactory.categories().replaceAll(with: cats)
        try oldFactory.categories().deleteAll()

        // Accounts
        let accs = try oldFactory.accounts().all()
        for acc in accs {
            try newFactory.accounts().create(acc)
        }
        try oldFactory.accounts().deleteAll()

        // Backup
        let items = try oldFactory.backup().items()
        for item in items {
            try newFactory.backup().upsert(item)
        }
        try oldFactory.backup().deleteAll()

        // Фиксируем в настройках, что миграция выполнена
        defaults.set(current.rawValue, forKey: "last_storage_method")
    }
}
