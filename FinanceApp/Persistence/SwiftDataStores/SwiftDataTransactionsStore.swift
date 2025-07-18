//
//  SwiftDataTransactionsStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataTransactionsStore: TransactionsStore {
    private let context = SwiftDataContainerProvider.shared.mainContext

    func all() throws -> [Transaction] {
        let ents = try context.fetch(FetchDescriptor<TransactionEntity>())
        return ents.map(\.model)
    }

    func transaction(id: Int) throws -> Transaction? {
        let ents = try context.fetch(
            FetchDescriptor<TransactionEntity>(
                predicate: #Predicate { $0.id == id }
            )
        )
        return ents.first?.model
    }

    func create(_ tx: Transaction) throws {
        context.insert(TransactionEntity(from: tx))
        try context.save()
    }

    func update(_ tx: Transaction) throws {
        // fetch, then first
        let ents = try context.fetch(
            FetchDescriptor<TransactionEntity>(
                predicate: #Predicate { $0.id == tx.id }
            )
        )
        guard let ent = ents.first else {
            throw PersistenceError.notFound(id: tx.id)
        }

        ent.accountId       = tx.accountId
        ent.categoryId      = tx.categoryId
        ent.amount          = tx.amount
        ent.transactionDate = tx.transactionDate
        ent.comment         = tx.comment
        try context.save()
    }

    func delete(id: Int) throws {
        let ents = try context.fetch(
            FetchDescriptor<TransactionEntity>(
                predicate: #Predicate { $0.id == id }
            )
        )
        if let ent = ents.first {
            context.delete(ent)
            try context.save()
        }
    }
}
