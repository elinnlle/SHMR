//
//  CurrencyPickerCard.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 27.06.2025.
//

import SwiftUI

struct CurrencyPickerCard: View {
    let currencies: [Currency]
    let current: Currency
    var onSelect: (Currency) -> Void

    static let titleHeight: CGFloat = 44 // заголовок
    static let rowHeight: CGFloat = 56 // строка валюты

    var body: some View {
        VStack(spacing: 0) {
            // Заголовок «Валюта»
            Text("Валюта")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, minHeight: Self.titleHeight)
                .background(Color(uiColor: .systemGray5))

            Divider()

            // Строки с валютами
            ForEach(currencies) { currency in
                Button {
                    onSelect(currency)
                } label: {
                    Text("\(currency.name) \(currency.symbol)")
                        .frame(maxWidth: .infinity, minHeight: Self.rowHeight)
                        .foregroundColor(
                            currency == current
                                ? .secondary
                                : Color("PurpleAccent")
                        )
                }
                .disabled(currency == current)
                .background(Color(uiColor: .systemGray5))

                if currency.id != currencies.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(uiColor: .systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 0)
    }
}


