//
//  BackupEntity.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import SwiftData

/// Сущность для хранения оффлайн‑очереди операций.
@Model
final class BackupEntity {
    @Attribute(.unique) var id: Int
    var actionRaw: String
    var payloadData: Data?

    init(
        id: Int,
        actionRaw: String,
        payloadData: Data?
    ) {
        self.id          = id
        self.actionRaw   = actionRaw
        self.payloadData = payloadData
    }

    var item: BackupItem {
        BackupItem(
            id: id,
            action: BackupAction(rawValue: actionRaw)!,
            payload: payloadData
        )
    }

    convenience init(from item: BackupItem) {
        self.init(
            id: item.id,
            actionRaw: item.action.rawValue,
            payloadData: item.payload
        )
    }
}
