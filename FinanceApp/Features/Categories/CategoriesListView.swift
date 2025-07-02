//
//  CategoriesListView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 01.07.2025.
//

import SwiftUI

struct CategoriesListView: View {

    let categories: [Category]

    init(categories: [Category] = []) {
        self.categories = categories
    }

    @State private var searchText = ""

    private var filtered: [Category] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return categories
        }
        return categories.filter { $0.name.fuzzyContains(query) }
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
    }
}

#Preview {
    let sampleCategories: [Category] = [
        Category(id: 1, name: "Аренда квартиры",   emoji: "🏠", isIncome: false),
        Category(id: 2, name: "Одежда",            emoji: "👔", isIncome: false),
        Category(id: 3, name: "На собачку",        emoji: "🐕", isIncome: false),
        Category(id: 4, name: "Ремонт квартиры",   emoji: "🔨", isIncome: false),
        Category(id: 5, name: "Продукты",          emoji: "🍬", isIncome: false),
        Category(id: 6, name: "Спортзал",          emoji: "🏋️‍♀️", isIncome: false),
        Category(id: 7, name: "Медицина",          emoji: "💊", isIncome: false),
        Category(id: 8, name: "Аптека",            emoji: "💜", isIncome: false),
        Category(id: 9, name: "Машина",            emoji: "🚗", isIncome: false)
    ]

    NavigationStack {
        CategoriesListView(categories: sampleCategories)
    }
}
