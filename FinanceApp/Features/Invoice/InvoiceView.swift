//
//  InvoiceView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import SwiftUI

struct InvoiceView: View {
    @EnvironmentObject private var ui: UIEvents
    @EnvironmentObject private var services: ServicesContainer

    let accountId: Int
    @StateObject private var viewModel: InvoiceViewModel
    
    @State private var showCurrencySheet = false
    
    // Высоты строк в CurrencyPickerCard
    private let headerHeight: CGFloat = 44
    private let rowHeight:    CGFloat = 56
    
    init(accountId: Int) {
        self.accountId = accountId
        _viewModel = StateObject(
            wrappedValue: InvoiceViewModel(accountId: accountId)
        )
    }

    var body: some View {
        NavigationStack {
            List {
                contentSections
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 4) }
            // Жест для скрытия клавиатуры
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        if viewModel.isEditing {
                            hideKeyboard()
                        }
                    }
            )
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "Сохранить" : "Редактировать") {
                        if viewModel.isEditing {
                            withAnimation { showCurrencySheet = false }
                            viewModel.saveChanges()
                            hideKeyboard()
                        } else {
                            viewModel.startEditing()
                        }
                    }
                    .foregroundColor(Color("PurpleAccent"))
                }
            }
            .refreshable {
                await ui.run {
                    try await viewModel.refresh()
                }
            }
            .withLoadAndAlerts()
            .onAppear {
                Task {
                    await ui.run {
                        try await viewModel.refresh()
                    }
                }
            }
            .accentColor(Color("PurpleAccent"))
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .overlay(shakeDetectorOverlay)
            .overlay(currencyPickerOverlay)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCurrencySheet)
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: UIApplication.shared.bottomSafeAreaInset)
        }
    }

    @ViewBuilder
    private var contentSections: some View {
        if viewModel.isEditing {
            Section {
                HStack {
                    Text("💰")
                    Text("Баланс")
                    Spacer()
                    TextField("0", text: $viewModel.balanceInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                }
            }
            Section {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(viewModel.currency.symbol)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { showCurrencySheet = true } }
            }
        } else {
            Section {
                HStack {
                    Text("💰")
                    Text("Баланс")
                    Spacer()
                    Text(viewModel.formattedBalance)
                        .spoiler(isOn: $viewModel.isBalanceHidden)
                }
                .foregroundColor(.black)
                .listRowBackground(Color("AccentColor"))
            }
            Section {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(viewModel.currency.symbol)
                }
                .listRowBackground(Color("AccentColor").opacity(0.2))
            }
            Section {
                BalanceHistoryChartView(
                    points: viewModel.points,
                    period: viewModel.period
                )
            .frame(height: 230)
            .padding(.horizontal, -14)
            .listRowBackground(Color.clear)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            Section {
                Picker("", selection: $viewModel.period) {
                    ForEach(ChartPeriod.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.blue)
                // меняем размер segmented control
                .scaleEffect(x: 1.35, y: 1.35, anchor: .center)
                .padding(.horizontal, 27)
            }
           .listRowBackground(Color.clear)
            // меняем шрифт внутри segmented control
           .onAppear {
               let font = UIFont.systemFont(ofSize: 11)
               let attrs: [NSAttributedString.Key: Any] = [
                   .font: font,
                   .foregroundColor: UIColor.label
               ]
               UISegmentedControl.appearance().setTitleTextAttributes(attrs, for: .normal)
               UISegmentedControl.appearance().setTitleTextAttributes(attrs, for: .selected)
           }
            
        }
    }

    private var shakeDetectorOverlay: some View {
        Group {
            if !viewModel.isEditing {
                ShakeDetector {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.toggleHidden()
                    }
                }
                .frame(width: 0, height: 0)
            }
        }
    }

    private var currencyPickerOverlay: some View {
        let totalCardHeight = headerHeight + rowHeight * CGFloat(Currency.all.count)
       
        var bottomInset: CGFloat {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .safeAreaInsets.bottom ?? 0
        }


        return ZStack {
            if showCurrencySheet {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showCurrencySheet = false }
                    }
            }

            GeometryReader { proxy in
                VStack {
                    Spacer()
                    CurrencyPickerCard(
                        currencies: Currency.all,
                        current: viewModel.currency
                    ) { selected in
                        viewModel.currency = selected
                        withAnimation { showCurrencySheet = false }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, bottomInset + 25)
                    .offset(y: showCurrencySheet
                            ? 0
                            : totalCardHeight + bottomInset + 40
                    )
                }
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
