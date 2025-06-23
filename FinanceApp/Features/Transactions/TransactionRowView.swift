
//  TransactionRowView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Text("💸")
                .font(.system(size: 24))
            VStack(alignment: .leading) {
                Text("Категория #\(transaction.categoryId)")
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(transaction.formattedAmount)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sample = Transaction(
        id: 1,
        accountId: 1,
        categoryId: 2,
        amount: Decimal(string: "1000")!,
        comment: "Пример",
        transactionDate: Date(),
        createdAt: Date(),
        updatedAt: Date()
    )
    TransactionRowView(transaction: sample)
}
