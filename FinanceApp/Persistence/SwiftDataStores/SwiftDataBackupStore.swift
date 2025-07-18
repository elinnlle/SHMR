//
//  SwiftDataBackupStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataBackupStore: BackupStore {
    private let context = SwiftDataContainerProvider.shared.mainContext

    func items() throws -> [BackupItem] {
        let ents = try context.fetch(FetchDescriptor<BackupEntity>())
        return ents.map(\.item)
    }

    func upsert(_ item: BackupItem) throws {
        let ents = try context.fetch(
            FetchDescriptor<BackupEntity>(
                predicate: #Predicate { $0.id == item.id }
            )
        )
        if let existing = ents.first {
            existing.actionRaw   = item.action.rawValue
            existing.payloadData = item.payload
        } else {
            context.insert(BackupEntity(from: item))
        }
        try context.save()
    }

    func remove(id: Int) throws {
        let ents = try context.fetch(
            FetchDescriptor<BackupEntity>(
                predicate: #Predicate { $0.id == id }
            )
        )
        if let ent = ents.first {
            context.delete(ent)
            try context.save()
        }
    }
}
