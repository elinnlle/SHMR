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

        var direction: Direction? {
            switch self {
            case .outcome: return .outcome
            case .income:  return .income
            default:       return nil
            }
        }
    }

    @State private var selection: Tab = .outcome

    var body: some View {
        ZStack {
            Group {
                switch selection {
                case .outcome:
                    NavigationStack {
                        TransactionsListView(direction: .outcome)
                    }
                    .tint(Color("PurpleAccent"))

                case .income:
                    NavigationStack {
                        TransactionsListView(direction: .income)
                    }
                    .tint(Color("PurpleAccent"))
                    
                case .invoice:
                    NavigationStack {
                        InvoiceView()
                    }
                    .tint(Color("PurpleAccent"))

                case .categories:
                    NavigationStack {
                        CategoriesListView()
                    }
                    .tint(Color("PurpleAccent"))

                case .settings:
                    NavigationStack {
                        Text("Настройки").font(.largeTitle)
                    }
                    .tint(Color("PurpleAccent"))
                }
            }
            .ignoresSafeArea(edges: .bottom)

            GeometryReader { geo in
                let bottom = geo.safeAreaInsets.bottom
                VStack {
                    Spacer()
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button {
                                selection = tab
                            } label: {
                                VStack(spacing: 4) {
                                    Image(tab.iconName)
                                        .renderingMode(.template)
                                        .frame(width: 24, height: 24)
                                    Text(tab.title)
                                        .font(.caption)
                                }
                                .foregroundColor(selection == tab
                                                 ? Color("AccentColor")
                                                 : Color.gray)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, bottom > 0 ? bottom : 16)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
                    )
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    MainTabView()
}
