//
//  CategoryEntity.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String // Храним emoji в виде строки длины 1
    var isIncome: Bool

    init(
        id: Int,
        name: String,
        emoji: String,
        isIncome: Bool
    ) {
        self.id       = id
        self.name     = name
        self.emoji    = emoji
        self.isIncome = isIncome
    }

    var model: Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first!,
            isIncome: isIncome
        )
    }

    /// Быстрое создание Entity из бизнес‑модели
    convenience init(from category: Category) {
        self.init(
            id: category.id,
            name: category.name,
            emoji: String(category.emoji),
            isIncome: category.isIncome
        )
    }
}
