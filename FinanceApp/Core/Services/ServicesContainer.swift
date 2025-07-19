//
//  ServicesContainer.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation
import Combine

@MainActor
final class ServicesContainer: ObservableObject {
    let transactions = TransactionsService()
    let accounts     = BankAccountsService()
    let categories   = CategoriesService()
    let network      = NetworkStatusService()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        network.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
