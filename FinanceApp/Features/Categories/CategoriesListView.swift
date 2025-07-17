//
//  CategoriesListView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 01.07.2025.
//

import SwiftUI

struct CategoriesListView: View {

    @EnvironmentObject private var ui: UIEvents
    @EnvironmentObject private var services: ServicesContainer
    @StateObject private var viewModel: CategoriesListViewModel
    @State private var searchText = ""
    
    init() {
        _viewModel = StateObject(
            wrappedValue: CategoriesListViewModel()
        )
    }

    private var filtered: [Category] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return viewModel.categories
        }
        return viewModel.categories.filter { $0.name.fuzzyContains(query) }
    }
    
    var body: some View {
        List {
            Section(header: Text("СТАТЬИ")
                        .font(.caption)
                        .foregroundColor(.secondary)) {
                ForEach(filtered) { category in
                    HStack(spacing: 12) {
                        Text(String(category.emoji))
                            .font(.system(size: 12))
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(Color("AccentColor").opacity(0.2))
                            )
                        Text(category.name)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .offset(y: -14)
        .listStyle(.insetGrouped)
        .navigationTitle("Мои статьи")
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Поиск") /// Не Search, потому что у меня русское приложение!🙃
        .autocorrectionDisabled(false)
        .withLoadAndAlerts()
        .onAppear {
            Task {
                await ui.run {
                    try await viewModel.reload()
                }
            }
        }

    }
}

#Preview {
    NavigationStack {
        CategoriesListView()
        .environmentObject(UIEvents())
    }
}
