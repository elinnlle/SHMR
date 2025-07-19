//
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    let accountId: Int

    @EnvironmentObject private var ui: UIEvents
    @StateObject private var viewModel = TransactionsListViewModel()
    @State private var formMode: FormMode?

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
                ForEach(viewModel.transactions) { tx in
                        Button {
                            formMode = .edit(tx)
                        } label: {
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
                    HistoryView(direction: direction, accountId: accountId)
                } label: {
                    Image("HistoryIcon")
                        .renderingMode(.template)
                        .foregroundColor(Color("PurpleAccent"))
                }
            }
        }
        .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
        .overlay(
            Button {
                formMode = .create
            } label: {
                Image("PlusIcon")
                    .resizable()
                    .frame(width: 56, height: 56)
            }
                .padding(.trailing, 16)
                .padding(.bottom, 46),
            alignment: .bottomTrailing
        )
        .sheet(item: $formMode,
               onDismiss: {
            viewModel.load(direction: direction, accountId: accountId)
        }
        ) { mode in
            let tfMode: TransactionFormView.Mode = {
                switch mode {
                case .create:
                    return .create
                case .edit(let tx):
                    return .edit(tx)
                }
            }()

            TransactionFormView(mode: tfMode, direction: direction)
        }

        .withLoadAndAlerts()
        .onAppear {
            Task {
                await ui.run {
                    try await viewModel.reload(direction: direction, accountId: accountId)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: UIApplication.shared.bottomSafeAreaInset)
        }
    }
}

struct CreateTransactionView: View {
    let direction: Direction

    var body: some View {
        VStack {
            Text("Создание операции")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationTitle(direction == .income ? "Новый доход" : "Новый расход")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum FormMode: Identifiable {
    case create
    case edit(Transaction)

    var id: Int {
        switch self {
        case .create:
            return -1
        case .edit(let tx):
            return tx.id
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsListView(direction: .outcome, accountId: 0)
    }
}
