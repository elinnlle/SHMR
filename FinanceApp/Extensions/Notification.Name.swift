//
//  Notification.Name.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 14.07.2025.
//

import Foundation

extension Notification.Name {
    /// Срабатывает после любого создания/редактирования/удаления транзакции
    static let transactionsChanged = Notification.Name("transactionsChanged")
}
