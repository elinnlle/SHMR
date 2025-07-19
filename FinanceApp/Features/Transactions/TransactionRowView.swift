//
//  TransactionRowView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    // MARK: – Категория
    @State private var category: Category?
    private let catsService: CategoriesServiceProtocol = CategoriesService()

    private var categoryName: String { category?.name ?? "Категория" }
    private var categoryEmoji: String { String(category?.emoji ?? "💸") }

    var body: some View {
        HStack(spacing: 12) {
            // Эмоджи-иконка
            Text(categoryEmoji)
                .font(.system(size: 12))
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(Color("AccentColor").opacity(0.2))
                )

            // Название категории + комментарий
            VStack(alignment: .leading, spacing: 2) {
                Text(categoryName)
                    .font(.body)
                    .foregroundColor(.primary)

                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Сумма
            Text(transaction.formattedAmount)
                .font(.body)
                .foregroundColor(.primary)

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .task(id: transaction.categoryId) {
            await loadCategory()
        }

    }

    private func loadCategory() async {
        do {
            let cats = try await catsService.categories()
            category = cats.first { $0.id == transaction.categoryId }
        } catch {
            category = nil
        }
    }
}
