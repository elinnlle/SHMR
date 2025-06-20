//
//  HistoryView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct HistoryView: View {
    let direction: Direction

    @State private var startDate: Date = Date().monthAgo
    @State private var endDate:   Date = Date()
    @State private var sortOption: SortOption = .date

    @State private var showStartPicker = false
    @State private var showEndPicker   = false

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        List {
            Section {
                Button { showStartPicker = true } label: {
                    HStack {
                        Text("Начало")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(startDate, formatter: Self.dateTimeFormatter)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color("AccentColor").opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                    }
                }
                .sheet(isPresented: $showStartPicker) {
                    VStack {
                        DatePicker(
                            "Выберите начало",
                            selection: $startDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .tint(Color("AccentColor"))
                        .padding()
                        Button("Готово") { showStartPicker = false }
                            .padding(.top, 8)
                    }
                }

                Button { showEndPicker = true } label: {
                    HStack {
                        Text("Конец")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(endDate, formatter: Self.dateTimeFormatter)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color("AccentColor").opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                    }
                }
                .sheet(isPresented: $showEndPicker) {
                    VStack {
                        DatePicker(
                            "Выберите конец",
                            selection: $endDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .tint(Color("AccentColor"))
                        .padding()
                        Button("Готово") { showEndPicker = false }
                            .padding(.top, 8)
                    }
                }

                HStack {
                    Text("Сумма")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.totalFormatted)
                }

                // Сегмент сортировки
                Picker("", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color(.systemBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 13, bottom: 8, trailing: 13))
            }
            .textCase(nil)

            Section("ОПЕРАЦИИ") {
                LazyVStack {
                    ForEach(viewModel.sortedTransactions) { tx in
                        TransactionRowView(transaction: tx)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Моя история")
        .onAppear {
            reload()
        }
        .onChange(of: startDate) { oldValue, newValue in
            if newValue > endDate {
                endDate = newValue
            }
            reload()
        }
        .onChange(of: endDate) { oldValue, newValue in
            if newValue < startDate {
                startDate = newValue
            }
            reload()
        }
        .onChange(of: sortOption) { _, _ in
            viewModel.applySort(option: sortOption)
        }
    }

    private func reload() {
        viewModel.load(
            direction: direction,
            start: startDate.startOfDay,
            end:   endDate.endOfDay,
            sort:  sortOption
        )
    }

    enum SortOption: CaseIterable {
        case date, amount
        var title: String {
            switch self {
            case .date:   return "По дате"
            case .amount: return "По сумме"
            }
        }
    }

    // Формат даты и времени
    /// Я решила везде отображать время, так мне кажется логичнее
    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale     = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f
    }()
}

extension HistoryView {
    @MainActor
    final class ViewModel: ObservableObject {
        private let service: TransactionsServiceProtocol = TransactionsServiceMock()
        @Published private(set) var transactions:       [Transaction] = []
        @Published private(set) var sortedTransactions: [Transaction] = []
        @Published private(set) var total:              Decimal       = 0

        func load(
            direction: Direction,
            start: Date,
            end: Date,
            sort: HistoryView.SortOption
        ) {
            Task {
                do {
                    let all = try await service.transactions(
                        for: 1,
                        from: start,
                        to:   end
                    )
                    let filtered = all.filter { $0.deducedDirection == direction }
                    let sum      = filtered.reduce(.zero) { $0 + $1.amount }
                    await MainActor.run {
                        self.transactions = filtered
                        self.total        = sum
                        self.applySort(option: sort)
                    }
                } catch {
                    print("History load error:", error)
                }
            }
        }

        func applySort(option: HistoryView.SortOption) {
            switch option {
            case .date:
                sortedTransactions = transactions
                    .sorted { $0.transactionDate > $1.transactionDate }
            case .amount:
                sortedTransactions = transactions
                    .sorted { $0.amount > $1.amount }
            }
        }

        var totalFormatted: String {
            let nf = NumberFormatter()
            nf.numberStyle    = .currency
            nf.locale         = Locale(identifier: "ru_RU")
            nf.currencySymbol = "₽"
            return nf.string(for: total) ?? "\(total) ₽"
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(direction: .outcome)
    }
}
