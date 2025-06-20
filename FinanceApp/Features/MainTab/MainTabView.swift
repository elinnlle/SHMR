//
//  MainTabView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable, CaseIterable {
        case outcome, income, invoice, articles, settings

        var title: String {
            switch self {
            case .outcome: return "Расходы"
            case .income:  return "Доходы"
            case .invoice: return "Счет"
            case .articles:return "Статьи"
            case .settings:return "Настройки"
            }
        }

        var iconName: String {
            switch self {
            case .outcome: return "OutcomeIcon"
            case .income:  return "IncomeIcon"
            case .invoice: return "InvoiceIcon"
            case .articles:return "ArticlesIcon"
            case .settings:return "SettingsIcon"
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
                case .outcome, .income:
                    NavigationStack {
                        TransactionsListView(direction: selection.direction!)
                    }
                    .tint(Color("PurpleAccent"))

                case .invoice:
                    NavigationStack {
                        Text("Счет").font(.largeTitle)
                    }
                    .tint(Color("PurpleAccent"))

                case .articles:
                    NavigationStack {
                        Text("Статьи").font(.largeTitle)
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
