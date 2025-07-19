//
//  TransactionFormView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.07.2025.
//

import SwiftUI

struct TransactionFormView: View {
    enum Mode: Equatable {
        case create
        case edit(Transaction)
    }

    let mode: Mode
    let direction: Direction

    @EnvironmentObject private var ui: UIEvents
    @Environment(\.dismiss) private var dismiss

    @State private var categories: [Category] = []
    @State private var showCategoryPicker = false

    @State private var selectedCategory: Category?
    @State private var amountText: String = ""
    @State private var date: Date = .now
    @State private var time: Date = .now
    @State private var comment: String = ""
    @State private var showValidationError = false

    private let txnService: TransactionsServiceProtocol      = TransactionsService()
    private let accountsService: BankAccountsServiceProtocol = BankAccountsService()
    private let catsService: CategoriesServiceProtocol       = CategoriesService()
    @State private var account: BankAccount?

    private let decimalSeparator = Locale.current.decimalSeparator ?? "."
    private var allowedCharacters: CharacterSet {
        var set = CharacterSet.decimalDigits
        set.insert(charactersIn: decimalSeparator)
        return set
    }
    private var amountValue: Decimal? {
        let normalized = amountText.replacingOccurrences(of: decimalSeparator, with: ".")
        return Decimal(string: normalized)
    }
    private var isFormValid: Bool {
        account != nil &&
        selectedCategory != nil &&
        (amountValue ?? 0) > 0
    }

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        HStack {
                            Text("Статья")
                            Spacer()
                            Button { showCategoryPicker = true } label: {
                                Text(selectedCategory?.name ?? "Выберите статью")
                                    .foregroundColor(selectedCategory == nil ? .gray : .primary)
                            }
                        }
                        HStack {
                            Text("Сумма")
                            Spacer()
                            TextField("0", text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: amountText, perform: filterAmountInput)
                        }
                        DatePicker("Дата", selection: $date, in: ...Date(), displayedComponents: .date)
                            .tint(Color("AccentColor"))
                        DatePicker("Время", selection: $time, displayedComponents: .hourAndMinute)
                            .tint(Color("AccentColor"))
                        ZStack(alignment: .topLeading) {
                            if comment.isEmpty {
                                Text("Комментарий")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                            TextEditor(text: $comment)
                                .frame(minHeight: 80)
                        }
                    }
                    if case .edit = mode {
                        Section {
                            Button(role: .destructive, action: deleteAction) {
                                Text("Удалить \(direction == .income ? "доход" : "расход")")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .navigationTitle(navigationTitle)
                .toolbar { toolbarItems }
                .alert("Заполните все поля", isPresented: $showValidationError) {
                    Button("Ок", role: .cancel) {}
                } message: {
                    Text("Пожалуйста, повторите попытку.")
                }
                .sheet(isPresented: $showCategoryPicker) {
                    CategoryPickerView(
                        direction: direction,
                        service: catsService,
                        selected: $selectedCategory
                    )
                }
            }
            if ui.isLoading {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            Task {
                await ui.run {
                    try await loadInitialData()
                }
            }
        }
    }

    // MARK: – Toolbar
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    guard isFormValid else {
                        showValidationError = true
                        return
                    }
                    Task {
                        await ui.run {
                            try await performSave()
                        }
                    }
                } label: {
                    Text(mode == .create ? "Создать" : "Сохранить")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") { dismiss() }
            }
        }
    }
    
    private func performSave() async throws {
        let finalDate = merge(date: date, time: time)
        let unsigned  = amountValue!
        let amountToSend = unsigned // или -unsigned для расходов, если нужно

        switch mode {
        case .create:
            let newTx = Transaction(
                id: .random(in: 10_000...99_999),
                accountId: account!.id,
                categoryId: selectedCategory!.id,
                amount: amountToSend,
                transactionDate: finalDate,
                comment: comment,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await txnService.create(newTx)

        case .edit(let tx):
            let updatedTx = Transaction(
                id: tx.id,
                accountId: tx.accountId,
                categoryId: selectedCategory!.id,
                amount: amountToSend,
                transactionDate: finalDate,
                comment: comment,
                createdAt: tx.createdAt,
                updatedAt: Date()
            )
            try await txnService.update(updatedTx)
        }

        // После успешного сохранения закроем экран
        dismiss()
    }


    // MARK: – Data & Actions
    private func filterAmountInput(_ newValue: String) {
        let filtered = newValue.unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()
        let parts = filtered.components(separatedBy: decimalSeparator)
        let limited = parts.count > 2
            ? parts[0] + decimalSeparator + parts[1]
            : filtered
        if limited != newValue {
            amountText = limited
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            return direction == .income ? "Новый доход" : "Новый расход"
        case .edit:
            return direction == .income ? "Мои доходы" : "Мои расходы"
        }
    }

    private func loadInitialData() async throws {
        do {
            let dirCats = try await catsService.categories(direction: direction)
            categories = dirCats.isEmpty
                ? try await catsService.categories()
                : dirCats
        } catch {
            categories = []
        }
        account = try? await accountsService.account()
        if case let .edit(tx) = mode {
            selectedCategory = categories.first { $0.id == tx.categoryId }
            let absAmount = direction == .income ? tx.amount : -tx.amount
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.locale = Locale.current
            amountText = formatter.string(from: NSDecimalNumber(decimal: abs(absAmount))) ?? ""
            date    = tx.transactionDate
            time    = tx.transactionDate
            comment = tx.comment ?? ""
        }
    }

    private func saveAction() {
        guard isFormValid, let cat = selectedCategory, let acc = account else {
            showValidationError = true
            return
        }
        let finalDate = merge(date: date, time: time)
        Task {
            do {
                let unsigned = amountValue!
                let amountToSend = unsigned
                switch mode {
                case .create:
                    let newTx = Transaction(
                        id: .random(in: 10_000...99_999),
                        accountId: acc.id,
                        categoryId: cat.id,
                        amount: amountToSend,
                        transactionDate: finalDate,
                        comment: comment,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    try await txnService.create(newTx)
                case .edit(let tx):
                    let updatedTx = Transaction(
                        id: tx.id,
                        accountId: acc.id,
                        categoryId: cat.id,
                        amount: amountToSend,
                        transactionDate: finalDate,
                        comment: comment,
                        createdAt: tx.createdAt,
                        updatedAt: Date()
                    )
                    try await txnService.update(updatedTx)
                }
                dismiss()
            } catch {
                print("Ошибка при сохранении транзакции: \(error)")
            }
        }
    }

    private func deleteAction() {
        if case let .edit(tx) = mode {
            Task {
                do {
                    try await txnService.delete(id: tx.id)
                    dismiss()
                } catch {
                    print("Ошибка при удалении: \(error)")
                }
            }
        }
    }

    private func merge(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        var dc = cal.dateComponents([.year, .month, .day], from: date)
        let tc = cal.dateComponents([.hour, .minute, .second], from: time)
        dc.hour   = tc.hour
        dc.minute = tc.minute
        dc.second = tc.second
        return cal.date(from: dc) ?? date
    }
}
