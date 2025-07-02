//
//  String+Fuzzy.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 01.07.2025.
//

import Foundation

extension String {
    func fuzzyContains(_ pattern: String) -> Bool {
        let pattern = pattern.lowercased()
        guard !pattern.isEmpty else { return true }

        var currentIndex = pattern.startIndex
        for ch in self.lowercased() {
            if ch == pattern[currentIndex] {
                currentIndex = pattern.index(after: currentIndex)
                if currentIndex == pattern.endIndex {
                    return true
                }
            }
        }
        return false
    }
}
