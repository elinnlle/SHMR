//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

@MainActor
final class CategoriesService: CategoriesServiceProtocol {
    
    private let client: NetworkClient
    private let store:  CategoriesStore
    private let decoder = JSONDecoder()

    init(
        client: NetworkClient        = .init(),
        store:  CategoriesStore?     = nil
    ) {
        self.client = client
        self.store  = store  ?? SwiftDataCategoriesStore()
    }
    
    func categories() async throws -> [Category] {
        do {
            let remote: [Category] = try await client.request(
                "/categories",
                method: .get,
                body: Optional<EmptyBody>.none
            )
            try store.replaceAll(with: remote)
            return remote
        } catch {
            return try store.all()
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let all = try await categories()
        return all.filter { $0.isIncome == (direction == .income) }
    }
}
