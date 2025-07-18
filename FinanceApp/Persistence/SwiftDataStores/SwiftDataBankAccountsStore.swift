//
//  SwiftDataBankAccountsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataBankAccountsStore: BankAccountsStore {
    private let context = SwiftDataContainerProvider.shared.mainContext

    func all() throws -> [BankAccount] {
        let ents = try context.fetch(FetchDescriptor<BankAccountEntity>())
        return ents.map(\.model)
    }

    func account(id: Int) throws -> BankAccount? {
        let ents = try context.fetch(
            FetchDescriptor<BankAccountEntity>(
                predicate: #Predicate { $0.id == id }
            )
        )
        return ents.first?.model
    }

    func create(_ account: BankAccount) throws {
        context.insert(BankAccountEntity(from: account))
        try context.save()
    }

    func update(_ account: BankAccount) throws {
        let ents = try context.fetch(
            FetchDescriptor<BankAccountEntity>(
                predicate: #Predicate { $0.id == account.id }
            )
        )
        guard let ent = ents.first else {
            throw PersistenceError.notFound(id: account.id)
        }
        ent.name    = account.name
        ent.balance = account.balance
        try context.save()
    }

    func delete(id: Int) throws {
        let ents = try context.fetch(
            FetchDescriptor<BankAccountEntity>(
                predicate: #Predicate { $0.id == id }
            )
        )
        if let ent = ents.first {
            context.delete(ent)
            try context.save()
        }
    }
}
