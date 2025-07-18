//
//  PersistenceError.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

enum PersistenceError: Error {
    /// Сущность не найдена по запросу.
    case notFound(id: Int)
    /// Ошибка при сохранении изменений.
    case saveFailed(underlying: Error)
    /// Ошибка при удалении.
    case deleteFailed(underlying: Error)
    /// Общая I/O-ошибка.
    case ioError(underlying: Error)
}
