//
//  InvoiceViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation
import Combine

@MainActor
final class InvoiceViewModel: ObservableObject {
    @Published var balance: Decimal = 0
    @Published var currency: Currency = .rub
    @Published var isEditing: Bool = false
    @Published var isBalanceHidden: Bool = false

    @Published var balanceInput: String = "" {
        didSet {
            let filtered = balanceInput.filter { "0123456789-., ".contains($0) }
            if filtered != balanceInput {
                balanceInput = filtered
            }
        }
    }

    func startEditing() {
        balanceInput = formattedBalanceRaw
        isEditing = true
    }

    func saveChanges() {
        let normalized = balanceInput
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        if let decimal = Decimal(string: normalized) {
            balance = decimal
        }
        isEditing = false
    }

    func selectCurrency(_ new: Currency) {
        guard new != currency else { return }
        currency = new
    }

    func refresh() async {
        do {
            // TODO: реализовать, когда будет работа с сетью
            // let result = try await API.shared.fetchAccount()
            // balance = result.balance
            // currency = result.currency
        } catch {
            print("Ошибка обновления:", error)
        }
    }

    func toggleHidden() {
        isBalanceHidden.toggle()
    }

    private var formattedBalanceRaw: String {
        numberFormatter.string(for: balance as NSDecimalNumber) ?? "0"
    }

    var formattedBalance: String {
        let sign = balance < 0 ? "-" : ""
        let amount = numberFormatter.string(for: abs(balance) as NSDecimalNumber) ?? "0"
        return "\(sign)\(amount) \(currency.symbol)"
    }

    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ru_RU")
        nf.numberStyle = .decimal
        nf.groupingSeparator = " "
        nf.decimalSeparator = ","
        nf.maximumFractionDigits = 2
        return nf
    }
}
