//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

final class CategoriesService: CategoriesServiceProtocol {
    
    private let client: NetworkClient
    
    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }
    
    func categories() async throws -> [Category] {
        try await client.request(
            "/categories",
            method: .get,
            body: Optional<EmptyBody>.none
        )
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let all = try await categories()
        return all.filter { $0.isIncome == (direction == .income) }
    }
}
