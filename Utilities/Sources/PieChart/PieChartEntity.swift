//
//  PieChartEntity.swift
//  Utilities
//
//  Created by Эльвира Матвеенко on 19.07.2025.
//

import Foundation

public struct PieChartEntity {
    public let value: Decimal
    public let label: String

    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}
