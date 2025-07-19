//
//  CategoriesStore.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation

@MainActor
protocol CategoriesStore {
    /// Возвращает все категории.
    func all() throws -> [Category]

    /// Пересохраняет список категорий (удаляет старые и сохраняет новые).
    func replaceAll(with categories: [Category]) throws
}
