//
//  UIEvents.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import SwiftUI

struct AlertData: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class UIEvents: ObservableObject {
    @Published var isLoading = false
    @Published var alert: AlertData?

    func run<T>(_ block: @escaping () async throws -> T) async -> T? {
        isLoading = true
        defer { isLoading = false }

        do {
            return try await block()
        } catch {
            alert = AlertData(title: "Ошибка", message: error.localizedDescription)
            print(error)
            return nil
        }
    }
}
