//
//  CategoriesServiceMock.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

final class CategoriesServiceMock: CategoriesServiceProtocol {
    private let all: [Category] = [
        .init(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
        .init(id: 2, name: "Продукты", emoji: "🛒", isIncome: false),
        .init(id: 3, name: "Транспорт", emoji: "🚗", isIncome: false),
        .init(id: 4, name: "Подписки", emoji: "🖥", isIncome: true)
    ]

    func categories() async throws -> [Category] {
        all
    }

    func categories(direction: Direction) async throws -> [Category] {
        all.filter { $0.direction == direction }
    }
}
