//
//  CategoryPickerView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.07.2025.
//

import SwiftUI

struct CategoryPickerView: View {
    let direction: Direction
    let service: CategoriesServiceProtocol

    @Binding var selected: Category?
    @Environment(\.dismiss) private var dismiss

    @State private var categories: [Category] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                } else if categories.isEmpty {
                    Text("Категории отсутствуют")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List(categories, id: \.id) { cat in
                        Button {
                            selected = cat
                            dismiss()
                        } label: {
                            HStack {
                                Text(String(cat.emoji))
                                Text(cat.name)
                                Spacer()
                                if cat.id == selected?.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выберите статью")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadCategories()
            }
        }
    }

    private func loadCategories() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let dirCats = try await service.categories(direction: direction)
            categories = dirCats.isEmpty
                ? try await service.categories()
                : dirCats
        } catch {
            categories = []
        }
    }
}
