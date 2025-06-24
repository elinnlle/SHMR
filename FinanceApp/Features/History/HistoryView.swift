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
    @Environment(\.presentationMode) private var presentationMode

    @State private var showStartPicker = false
    @State private var showEndPicker   = false

    @StateObject private var viewModel = HistoryViewModel()

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
        .listSectionSpacing(.compact)
        .navigationTitle("Моя история")
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                }
            }
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

#Preview {
    NavigationStack {
        HistoryView(direction: .outcome)
    }
}
