//
//  BackupStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

enum BackupAction: String, Codable {
    case create, update, delete
}

struct BackupItem: Identifiable, Codable, Hashable {
    let id: Int                     // идентификатор сущности, к которой относится действие
    var action: BackupAction        // тип действия
    var payload: Data?              // закодированная модель (для create/update)
}

@MainActor
protocol BackupStore {
    /// Все элементы очереди.
    func items() throws -> [BackupItem]

    /// Добавить или обновить элемент очереди.
    func upsert(_ item: BackupItem) throws

    /// Удалить элемент по идентификатору.
    func remove(id: Int) throws
}
