//
//  ServicesContainer.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

@MainActor
final class ServicesContainer: ObservableObject {
    let transactions = TransactionsService()
    let accounts     = BankAccountsService()
    let categories   = CategoriesService()
    let network = NetworkStatusService()
}
