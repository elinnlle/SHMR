//
//  CoreDataBackupStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData
import Foundation

@MainActor
final class CoreDataBackupStore: BackupStore {
    private let context = CoreDataContainerProvider.shared.container.viewContext

    // MARK: – BackupStore

    /// Возвращает все элементы очереди.
    func items() throws -> [BackupItem] {
        let request = NSFetchRequest<CDBackupItem>(entityName: "CDBackupItem")
        let cdItems = try context.fetch(request)
        return cdItems.map(\.model)
    }

    /// Добавить или обновить элемент очереди.
    func upsert(_ item: BackupItem) throws {
        if let existing = try backupManaged(id: item.id) {
            existing.fill(from: item)
        } else {
            let obj = CDBackupItem(context: context)
            obj.fill(from: item)
        }
        try save()
    }

    /// Удалить элемент по идентификатору.
    func remove(id: Int) throws {
        if let obj = try backupManaged(id: id) {
            context.delete(obj)
            try save()
        }
    }

    // MARK: – Helpers

    private func backupManaged(id: Int) throws -> CDBackupItem? {
        let req = NSFetchRequest<CDBackupItem>(entityName: "CDBackupItem")
        req.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(req).first
    }

    private func save() throws {
        do { try context.save() }
        catch { throw PersistenceError.saveFailed(underlying: error) }
    }
}
