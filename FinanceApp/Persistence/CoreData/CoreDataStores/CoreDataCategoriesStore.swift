//
//  CoreDataCategoriesStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData
import Foundation

@MainActor
final class CoreDataCategoriesStore: CategoriesStore {
    private let context = CoreDataContainerProvider.shared.container.viewContext

    func all() throws -> [Category] {
        let request = NSFetchRequest<CDCategory>(entityName: "CDCategory")
        let cdCats = try context.fetch(request)
        return cdCats.map(\.model)
    }

    func replaceAll(with categories: [Category]) throws {
        // удаляем все старые
        let deleteRequest = NSFetchRequest<CDCategory>(entityName: "CDCategory")
        let existing = try context.fetch(deleteRequest)
        for obj in existing {
            context.delete(obj)
        }

        // вставляем новые
        for cat in categories {
            let obj = CDCategory(context: context)
            obj.fill(from: cat)
        }

        // сохраняем
        try save()
    }

    // MARK: – Сохранение
    private func save() throws {
        do { try context.save() }
        catch { throw PersistenceError.saveFailed(underlying: error) }
    }
}
