//
//  InvoiceViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation

@MainActor
final class InvoiceViewModel: ObservableObject {
    @Published var balance: Decimal       = 0
    @Published var currency: Currency     = .rub
    @Published var isEditing: Bool        = false
    @Published var isBalanceHidden: Bool  = false
    @Published var balanceInput: String   = "" {
        didSet {
            let filtered = balanceInput.filter { "0123456789-., ".contains($0) }
            if filtered != balanceInput {
                balanceInput = filtered
            }
        }
    }

    private let service: BankAccountsServiceProtocol
    private var currentAccount: BankAccount?
    private let accountId: Int

    init(service: BankAccountsServiceProtocol = BankAccountsService(),
         accountId: Int
    ) {
        self.service = service
        self.accountId = accountId

        // Сразу в фоне подгружаем account
        Task {
            do {
                let acc = try await service.account()
                await MainActor.run {
                    self.currentAccount = acc
                    self.balance = acc.balance
                    if let c = Currency.all.first(where: { $0.code == acc.currency }) {
                        self.currency = c
                    }
                }
            } catch {
                print("Не удалось подгрузить account в init:", error)
            }
        }
    }


    func startEditing() {
        balanceInput = formattedBalanceRaw
        isEditing    = true
    }

    func saveChanges() {
        let normalized = balanceInput
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        if let dec = Decimal(string: normalized) {
            balance = dec
        }
        isEditing = false
        
        Task {
            do {
                guard var acc = currentAccount else {
                    print("Нет загруженного account для обновления")
                    return
                }
                acc.balance  = balance
                acc.currency = currency.code
                let updated = try await service.update(
                    account: acc
                )
                currentAccount = updated
                balance = updated.balance
                if let c = Currency.all.first(
                    where: {$0.code == updated.currency}) {currency = c}
            } catch {
                print("Ошибка при сохранении валюты:", error)
            }
        }
    }

    /// Обновляет баланс и валюту из сети
    func refresh() async throws {
        let acc = try await service.account()
        balance = acc.balance

        if let c = Currency.all.first(where: { $0.code == acc.currency }) {
            currency = c
        } else {
            print("Unknown currency:", acc.currency)
        }
    }

    func toggleHidden() {
        isBalanceHidden.toggle()
    }

    private var formattedBalanceRaw: String {
        numberFormatter.string(for: balance as NSDecimalNumber) ?? "0"
    }

    var formattedBalance: String {
        let sign   = balance < 0 ? "-" : ""
        let amount = numberFormatter.string(for: abs(balance) as NSDecimalNumber) ?? "0"
        return "\(sign)\(amount) \(currency.symbol)"
    }

    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.locale            = Locale(identifier: "ru_RU")
        nf.numberStyle       = .decimal
        nf.groupingSeparator = " "
        nf.decimalSeparator  = ","
        nf.maximumFractionDigits = 2
        return nf
    }
}

