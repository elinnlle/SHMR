//
//  SwiftDataContainerProvider.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import SwiftData

/// Один общий ModelContainer для всего приложения.
enum SwiftDataContainerProvider {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(
                // модели передаём без [ ]
                for: TransactionEntity.self,
                     BankAccountEntity.self,
                     CategoryEntity.self,
                     BackupEntity.self,
                // конфигурацию создаём просто по имени файла БД
                configurations: ModelConfiguration("FinanceAppStorage")
            )
        } catch {
            fatalError("Не удалось инициализировать SwiftData ModelContainer: \(error)")
        }
    }()
}
