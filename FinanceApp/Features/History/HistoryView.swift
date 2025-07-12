//
//  HistoryView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

private struct StartButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct EndButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct HistoryView: View {
    let direction: Direction

    @State private var startDate: Date = Date().monthAgo
    @State private var endDate:   Date = Date()
    @State private var sortOption: SortOption = .date
    @Environment(\.presentationMode) private var presentationMode

    @State private var showStartPicker = false
    @State private var showEndPicker   = false
    
    @State private var startButtonFrame: CGRect = .zero
    @State private var endButtonFrame: CGRect   = .zero

    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        ZStack {
            // Основной список
            List {
                Section {
                    // Кнопка для выбора начала
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
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: StartButtonFrameKey.self,
                                    value: geo.frame(in: .global)
                                )
                        }
                    )

                    // Кнопка для выбора конца
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
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: EndButtonFrameKey.self,
                                    value: geo.frame(in: .global)
                                )
                        }
                    )

                    // Итоговая сумма
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
            .onAppear { reload() }
            .onChange(of: startDate) { _, new in
                if new > endDate { endDate = new }
                reload()
            }
            .onChange(of: endDate) { _, new in
                if new < startDate { startDate = new }
                reload()
            }
            .onChange(of: sortOption) { _, _ in
                viewModel.applySort(option: sortOption)
            }
            
            // Фон затемнения при показе попапа
            if showStartPicker || showEndPicker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showStartPicker = false
                        showEndPicker = false
                    }
            }

            // Плавающий попап для начала
            if showStartPicker {
                DateTimePickerPopup(
                    date: $startDate,
                    isPresented: $showStartPicker
                )
                .frame(
                    width: DatePickerConstants.popupSize.width,
                    height: DatePickerConstants.popupSize.height
                )
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }

            // Плавающий попап для конца
            if showEndPicker {
                DateTimePickerPopup(
                    date: $endDate,
                    isPresented: $showEndPicker
                )
                .frame(
                    width: DatePickerConstants.popupSize.width,
                    height: DatePickerConstants.popupSize.height
                )
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cornerRadius(12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationTitle("Моя история")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AnalysisViewControllerWrapper(direction: direction)
                        .edgesIgnoringSafeArea(.all)
                } label: {
                    Image("AnalysisIcon")
                }
            }
        }
        .onPreferenceChange(StartButtonFrameKey.self) { startButtonFrame = $0 }
        .onPreferenceChange(EndButtonFrameKey.self)   { endButtonFrame   = $0 }
    }


    private func reload() {
        viewModel.load(
            direction: direction,
            start: startDate.startOfDay,
            end:   endDate.endOfDay,
            sort:  sortOption
        )
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
