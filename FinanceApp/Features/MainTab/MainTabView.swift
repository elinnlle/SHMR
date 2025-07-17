//
//  MainTabView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable, CaseIterable {
        case outcome, income, invoice, categories, settings

        var title: String {
            switch self {
            case .outcome:    return "Расходы"
            case .income:     return "Доходы"
            case .invoice:    return "Счет"
            case .categories: return "Статьи"
            case .settings:   return "Настройки"
            }
        }

        var iconName: String {
            switch self {
            case .outcome:    return "OutcomeIcon"
            case .income:     return "IncomeIcon"
            case .invoice:    return "InvoiceIcon"
            case .categories: return "CategoriesIcon"
            case .settings:   return "SettingsIcon"
            }
        }
    }

    @State private var selection: Tab = .outcome

    // Навигационные пути для каждой вкладки
    @State private var outcomePath    = NavigationPath()
    @State private var incomePath     = NavigationPath()
    @State private var invoicePath    = NavigationPath()
    @State private var categoriesPath = NavigationPath()
    @State private var settingsPath   = NavigationPath()

    private let accountId: Int = 103

    var body: some View {
        ZStack {
            content
            tabBar
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .outcome:
            NavigationStack(path: $outcomePath) {
                TransactionsListView(direction: .outcome, accountId: accountId)
                    .navigationDestination(for: Transaction.self) { tx in
                        TransactionFormView(mode: .edit(tx), direction: .outcome)
                    }
            }
            .tint(Color("PurpleAccent"))

        case .income:
            NavigationStack(path: $incomePath) {
                TransactionsListView(direction: .income, accountId: accountId)
                    .navigationDestination(for: Transaction.self) { tx in
                        TransactionFormView(mode: .edit(tx), direction: .income)
                    }
            }
            .tint(Color("PurpleAccent"))

        case .invoice:
            NavigationStack(path: $invoicePath) {
                InvoiceView(accountId: accountId)
            }
            .tint(Color("PurpleAccent"))

        case .categories:
            NavigationStack(path: $categoriesPath) {
                CategoriesListView()
            }
            .tint(Color("PurpleAccent"))

        case .settings:
            NavigationStack(path: $settingsPath) {
                Text("Настройки")
                    .font(.largeTitle)
            }
            .tint(Color("PurpleAccent"))
        }
    }

    private var tabBar: some View {
        GeometryReader { geo in
            let bottom = geo.safeAreaInsets.bottom
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            // Сначала закрываем все модалки
                            dismissAllModals()
                            // Если тапнули по активной вкладке — сбрасываем её путь
                            if selection == tab {
                                resetPath(for: tab)
                            }
                            // Меняем вкладку
                            selection = tab
                        } label: {
                            VStack(spacing: 4) {
                                Image(tab.iconName)
                                    .renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text(tab.title)
                                    .font(.caption)
                            }
                            .foregroundColor(
                                selection == tab
                                    ? Color("AccentColor")
                                    : Color.gray
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                .padding(.bottom, bottom > 0 ? bottom : 16)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
                )
            }
            .ignoresSafeArea()
        }
    }

    private func resetPath(for tab: Tab) {
        switch tab {
        case .outcome:    outcomePath    = NavigationPath()
        case .income:     incomePath     = NavigationPath()
        case .invoice:    invoicePath    = NavigationPath()
        case .categories: categoriesPath = NavigationPath()
        case .settings:   settingsPath   = NavigationPath()
        }
    }

    private func dismissAllModals() {
        // Пробегаем по всем сценам и закрываем представленные контроллеры
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.rootViewController?
                    .dismiss(animated: false, completion: nil)
            }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ServicesContainer())
    }
}
