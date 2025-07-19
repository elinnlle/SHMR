//
//  CoreDataBankAccountsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData
import Foundation

@MainActor
final class CoreDataBankAccountsStore: BankAccountsStore {
    private let context = CoreDataContainerProvider.shared.container.viewContext

    func all() throws -> [BankAccount] {
        try context.fetch(CDBankAccount.fetchRequest()).compactMap { ($0 as? CDBankAccount)?.model }
    }

    func account(id: Int) throws -> BankAccount? {
        let req = CDBankAccount.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(req).compactMap { ($0 as? CDBankAccount)?.model }.first
    }

    func create(_ acc: BankAccount) throws {
        let obj = CDBankAccount(context: context)
        obj.fill(from: acc)
        try save()
    }

    func update(_ acc: BankAccount) throws {
        guard let obj = try accountManaged(id: acc.id) else {
            throw PersistenceError.notFound(id: acc.id)
        }
        obj.fill(from: acc)
        try save()
    }

    func delete(id: Int) throws {
        if let obj = try accountManaged(id: id) {
            context.delete(obj)
            try save()
        }
    }

    private func accountManaged(id: Int) throws -> CDBankAccount? {
        let req = CDBankAccount.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(req).first as? CDBankAccount
    }

    private func save() throws {
        do { try context.save() }
        catch { throw PersistenceError.saveFailed(underlying: error) }
    }
}
