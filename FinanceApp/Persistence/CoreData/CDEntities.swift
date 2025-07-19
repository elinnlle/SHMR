//
//  CDEntities.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData
import Foundation

// MARK: – Transaction
@objc(CDTransaction)
final class CDTransaction: NSManagedObject {
    @NSManaged var id:             Int64
    @NSManaged var accountId:      Int64
    @NSManaged var categoryId:     Int64
    @NSManaged var amount:         NSDecimalNumber
    @NSManaged var transactionDate: Date
    @NSManaged var comment:        String?
    @NSManaged var createdAt:      Date
    @NSManaged var updatedAt:      Date
}

extension CDTransaction {
    /// Копируем данные из модели в Core Data-объект
    func fill(from tx: Transaction) {
        id              = Int64(tx.id)
        accountId       = Int64(tx.accountId)
        categoryId      = Int64(tx.categoryId)
        amount          = NSDecimalNumber(decimal: tx.amount)
        transactionDate = tx.transactionDate
        comment         = tx.comment
        createdAt       = tx.createdAt
        updatedAt       = tx.updatedAt
    }

    /// Обратно
    var model: Transaction {
        .init(
            id:             Int(id),
            accountId:      Int(accountId),
            categoryId:     Int(categoryId),
            amount:         amount.decimalValue,
            transactionDate: transactionDate,
            comment:        comment,
            createdAt:      createdAt,
            updatedAt:      updatedAt
        )
    }
}

// MARK: – Category
@objc(CDCategory)
final class CDCategory: NSManagedObject {
    @NSManaged var id:       Int64
    @NSManaged var name:     String
    @NSManaged var emoji:    String?
    @NSManaged var isIncome: Bool
}

extension CDCategory {
    func fill(from cat: Category) {
        id       = Int64(cat.id)
        name     = cat.name
        emoji    = String(cat.emoji)
        isIncome = cat.isIncome
    }

    var model: Category {
        guard let str = emoji, let ch = str.first else {
            fatalError("Emoji missing for CDCategory id \(id)")
        }
        return Category(
            id:       Int(id),
            name:     name,
            emoji:    ch,
            isIncome: isIncome
        )
    }
}

// MARK: – BankAccount
@objc(CDBankAccount)
final class CDBankAccount: NSManagedObject {
    @NSManaged var id:        Int64
    @NSManaged var name:      String
    @NSManaged var balance:   NSDecimalNumber
    @NSManaged var currency:  String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
}

extension CDBankAccount {
    func fill(from acc: BankAccount) {
        id        = Int64(acc.id)
        name      = acc.name
        balance   = NSDecimalNumber(decimal: acc.balance)
        currency  = acc.currency
        createdAt = acc.createdAt
        updatedAt = acc.updatedAt
    }

    var model: BankAccount {
        .init(
            id:        Int(id),
            name:      name,
            balance:   balance.decimalValue,
            currency:  currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: – BackupItem
@objc(CDBackupItem)
final class CDBackupItem: NSManagedObject {
    @NSManaged var id:      Int64
    @NSManaged var action:  String
    @NSManaged var payload: Data?
}

extension CDBackupItem {
    func fill(from item: BackupItem) {
        id      = Int64(item.id)
        action  = item.action.rawValue
        payload = item.payload
    }

    var model: BackupItem {
        .init(
            id:      Int(id),
            action:  BackupAction(rawValue: action) ?? .create,
            payload: payload
        )
    }
}
