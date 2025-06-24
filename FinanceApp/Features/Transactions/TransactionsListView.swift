//
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction

    @StateObject private var viewModel = TransactionsListViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Всего")
                    Spacer()
                    Text(viewModel.totalFormatted)
                }
            }

            Section("Операции") {
                LazyVStack {
                    ForEach(viewModel.transactions) { tx in
                        TransactionRowView(transaction: tx)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HistoryView(direction: direction)
                } label: {
                    Image("HistoryIcon")
                        .renderingMode(.template)
                        .foregroundColor(Color("PurpleAccent"))
                }
            }
        }
        .onAppear {
            viewModel.load(direction: direction)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsListView(direction: .outcome)
    }
}
