//
//  CategoryCodableTests.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import XCTest
@testable import FinanceApp

final class CategoryCodableTests: XCTestCase {
    func testEncodeDecodeRoundTrip() throws {
        let original = Category(id: 42, name: "Тест", emoji: "🧪", isIncome: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Category.self, from: data)
        XCTAssertEqual(decoded.id, 42)
        XCTAssertEqual(decoded.name, "Тест")
        XCTAssertEqual(decoded.emoji, "🧪")
        XCTAssertEqual(decoded.direction, .outcome)
    }
}
