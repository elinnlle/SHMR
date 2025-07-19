//
//  CoreDataContainerProvider.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData

final class CoreDataContainerProvider {
    static let shared = CoreDataContainerProvider()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let model = CoreDataModelBuilder.makeModel()

        container = NSPersistentContainer(name: "FinanceApp", managedObjectModel: model)

        let storeURL: URL
        if inMemory {
            storeURL = URL(fileURLWithPath: "/dev/null")
        } else {
            let appSupport = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
            // Убедимся, что папка существует
            try? FileManager.default.createDirectory(
                at: appSupport,
                withIntermediateDirectories: true,
                attributes: nil
            )
            storeURL = appSupport.appendingPathComponent("FinanceApp.sqlite")
        }

        let desc = NSPersistentStoreDescription(url: storeURL)
        desc.type = NSSQLiteStoreType
        // включаем легковесную миграцию
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true

        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("❌ Core Data load failed: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
