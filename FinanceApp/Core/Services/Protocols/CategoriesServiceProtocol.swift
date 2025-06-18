//
//  CategoriesServiceProtocol.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

protocol CategoriesServiceProtocol {
    func categories() async throws -> [Category]
    func categories(direction: Direction) async throws -> [Category]
}
