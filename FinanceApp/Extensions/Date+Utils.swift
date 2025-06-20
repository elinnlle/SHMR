//
//  Date+Utils.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import Foundation

extension Date {
    // 00:00 текущего дня
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    // 23:59:59 текущего дня
    var endOfDay: Date {
        let cal = Calendar.current
        let comps = DateComponents(hour: 23, minute: 59, second: 59)
        return cal.date(bySettingHour: comps.hour!,
                        minute: comps.minute!,
                        second: comps.second!,
                        of: self) ?? self
    }

    // Месяц назад от текущей даты
    var monthAgo: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
}
