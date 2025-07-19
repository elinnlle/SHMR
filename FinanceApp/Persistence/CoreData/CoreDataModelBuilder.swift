//
//  CoreDataModelBuilder.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import CoreData

/// Формируем `NSManagedObjectModel` без .xcdatamodeld.
enum CoreDataModelBuilder {
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: – Attribute helpers
        func decimal(_ name: String, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .decimalAttributeType
            a.isOptional    = optional
            return a
        }
        func int64(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .integer64AttributeType
            return a
        }
        func string(_ name: String, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .stringAttributeType
            a.isOptional    = optional
            return a
        }
        func date(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .dateAttributeType
            return a
        }
        func bool(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .booleanAttributeType
            return a
        }
        
        func binaryData(_ name: String, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .binaryDataAttributeType
            a.isOptional    = optional
            return a
        }

        // MARK: – CDTransaction
        let tx = NSEntityDescription()
        tx.name                   = "CDTransaction"
        tx.managedObjectClassName = String(describing: CDTransaction.self)
        tx.properties = [
            int64("id"),
            int64("accountId"),
            int64("categoryId"),
            decimal("amount"),
            date("transactionDate"),
            string("comment", optional: true),
            date("createdAt"),
            date("updatedAt")
        ]
        tx.uniquenessConstraints = [["id"]]

        // MARK: – CDCategory
        let cat = NSEntityDescription()
        cat.name                   = "CDCategory"
        cat.managedObjectClassName = String(describing: CDCategory.self)
        cat.properties = [
            int64("id"),
            string("name"),
            string("emoji", optional: true),
            bool("isIncome")
        ]
        cat.uniquenessConstraints = [["id"]]

        // MARK: – CDBankAccount
        let acc = NSEntityDescription()
        acc.name                   = "CDBankAccount"
        acc.managedObjectClassName = String(describing: CDBankAccount.self)
        acc.properties = [
            int64("id"),
            string("name"),
            decimal("balance"),
            string("currency"),
            date("createdAt"),
            date("updatedAt")
        ]
        acc.uniquenessConstraints = [["id"]]
        
        // MARK: – CDBackupItem
        let bck = NSEntityDescription()
        bck.name                   = "CDBackupItem"
        bck.managedObjectClassName = String(describing: CDBackupItem.self)
        bck.properties = [
            int64("id"),
            string("action"),
            binaryData("payload", optional: true)
        ]

        model.entities = [tx, cat, acc, bck]
        return model
    }
}
