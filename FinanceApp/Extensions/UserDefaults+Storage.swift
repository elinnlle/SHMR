//
//  UserDefaults+Storage.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

/// Способ локального хранения.
enum PersistenceMethod: String, CaseIterable, Codable {
    /// SwiftData — текущее хранилище проекта.
    case swiftData = "swift_data"
    /// Core Data.
    case coreData  = "core_data"
}

private let kStorageKey = "storage_method"

extension UserDefaults {
    /// Текущий выбранный способ хранения
    var storageMethod: PersistenceMethod {
        get { PersistenceMethod(rawValue: string(forKey: kStorageKey) ?? "") ?? .swiftData }
        set { set(newValue.rawValue, forKey: kStorageKey) }
    }
}
