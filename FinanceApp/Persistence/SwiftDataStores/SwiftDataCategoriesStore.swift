//
//  SwiftDataCategoriesStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoriesStore: CategoriesStore {
    private let container = SwiftDataContainerProvider.shared
    private var context: ModelContext { container.mainContext }

    func all() throws -> [Category] {
        try context.fetch(FetchDescriptor<CategoryEntity>()).map(\.model)
    }

    func replaceAll(with categories: [Category]) throws {
        // Удаляем всё старое
        let old = try context.fetch(FetchDescriptor<CategoryEntity>())
        old.forEach(context.delete)
        // Вставляем новое
        categories.forEach { context.insert(CategoryEntity(from: $0)) }
        do { try context.save() }
        catch { throw PersistenceError.saveFailed(underlying: error) }
    }
}
