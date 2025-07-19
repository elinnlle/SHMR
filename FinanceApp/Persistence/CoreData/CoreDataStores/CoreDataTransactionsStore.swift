//
//  CoreDataTransactionsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData
import Foundation

@MainActor
final class CoreDataTransactionsStore: TransactionsStore {
    private let context = CoreDataContainerProvider.shared.container.viewContext

    func all() throws -> [Transaction] {
        try context.fetch(CDTransaction.fetchRequest()).compactMap { ($0 as? CDTransaction)?.model }
    }

    func transaction(id: Int) throws -> Transaction? {
        let req = CDTransaction.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(req).compactMap { ($0 as? CDTransaction)?.model }.first
    }

    func create(_ tx: Transaction) throws {
        let obj = CDTransaction(context: context)
        obj.fill(from: tx)
        try save()
    }

    func update(_ tx: Transaction) throws {
        guard let obj = try transactionManaged(id: tx.id) else {
            throw PersistenceError.notFound(id: tx.id)
        }
        obj.fill(from: tx)
        try save()
    }

    func delete(id: Int) throws {
        if let obj = try transactionManaged(id: id) {
            context.delete(obj)
            try save()
        }
    }

    private func transactionManaged(id: Int) throws -> CDTransaction? {
        let req = CDTransaction.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(req).first as? CDTransaction
    }

    private func save() throws {
        do { try context.save() }
        catch { throw PersistenceError.saveFailed(underlying: error) }
    }
}
