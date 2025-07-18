//
//  CategoriesListViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

@MainActor
final class CategoriesListViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []

    private let service: CategoriesServiceProtocol

    init(service: CategoriesServiceProtocol? = nil) {
        self.service = service ?? CategoriesService()
    }

    /// Загружает список категорий с сервера
    func reload() async throws {
        let list = try await service.categories()
        categories = list
    }
}
