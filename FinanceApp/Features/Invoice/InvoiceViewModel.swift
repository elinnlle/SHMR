//
//  InvoiceViewModel.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import Foundation
import Charts
import Combine

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
    @Published var period: ChartPeriod = .day
    @Published private var dayPoints:   [BalancePoint] = []
    @Published private var monthPoints: [BalancePoint] = []

    var points: [BalancePoint] {
        period == .day ? dayPoints : monthPoints
    }

    private let txService: TransactionsServiceProtocol = TransactionsService()
    private let catService: CategoriesServiceProtocol = CategoriesService()
    private var incomeCategoryIds: Set<Int> = []
    
    private let service: BankAccountsServiceProtocol
    private var currentAccount: BankAccount?
    private let accountId: Int

    init(
        service: BankAccountsServiceProtocol? = nil,
        accountId: Int
    ) {
        // Здесь мы уже на MainActor
        self.service   = service ?? BankAccountsService()
        self.accountId = accountId

        // Сразу в фоне подгружаем account
        Task {
            do {
                let acc = try await self.service.account()
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
        }

        try await loadCategories()
        // одновременно загружаем обе серии
        async let dayLoad   = loadChartData(period: .day)
        async let monthLoad = loadChartData(period: .month)
        let (dPts, mPts)    = try await (dayLoad, monthLoad)

        dayPoints   = dPts
        monthPoints = mPts
    }
    
    private func loadCategories() async throws {
            let cats = try await catService.categories()
            incomeCategoryIds = Set(
                cats.filter { $0.isIncome }.map(\.id)
            )
        }
    
    // Перечитываем данные для графика
    func loadChartData(period: ChartPeriod) async throws -> [BalancePoint] {
        let end = Calendar.current.startOfDay(for: .now)
        let (start, count, comp): (Date, Int, Calendar.Component) = {
            switch period {
            case .day:
                let s = Calendar.current.date(byAdding: .day, value: -29, to: end)!
                return (s, 30, .day)
            case .month:
                let monthStart = Calendar.current.date(
                    from: Calendar.current.dateComponents([.year, .month], from: end)
                )!
                let s = Calendar.current.date(byAdding: .month, value: -24, to: monthStart)!
                return (s, 25, .month)
            }
        }()

        let txs = try await txService.transactions(
            for: accountId,
            from: start,
            to: Date()
        )
        let grouped = Dictionary(grouping: txs) {
            Calendar.current.dateInterval(of: comp, for: $0.transactionDate)!.start
        }

        return (0..<count).map { offset in
            let date = Calendar.current.date(
                byAdding: comp,
                value: offset,
                to: start
            )!
            let sum = grouped[date]?.reduce(Decimal.zero) { acc, tx in
                let signed = incomeCategoryIds.contains(tx.categoryId)
                           ? tx.amount
                           : -tx.amount
                return acc + signed
            } ?? 0
            return BalancePoint(date: date, amount: sum)
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

