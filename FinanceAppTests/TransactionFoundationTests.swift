//
//  TransactionFoundationTests.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import XCTest
@testable import FinanceApp

final class TransactionFoundationTests: XCTestCase {

    // Пример данных для парсинга
    private let sampleDict: [String: Any] = {
        // создаём Transaction с Int-идентификаторами
        let tx = Transaction(
            id: 101,
            accountId: 202,
            categoryId: 303,
            amount: Decimal(string: "123.45")!,
            transactionDate: Date(timeIntervalSince1970: 1_600_000_000),
            comment: "Test comment",
            createdAt:       Date(timeIntervalSince1970: 1_600_000_100),
            updatedAt:       Date(timeIntervalSince1970: 1_600_000_200)
        )
        // берём его jsonObject
        let raw = tx.jsonObject as! [String: Any]
        return raw
    }()

    func testParseValidJSONObject() throws {
        let parsed = Transaction.parse(jsonObject: sampleDict)
        XCTAssertNotNil(parsed, "parse(jsonObject:) вернул nil для валидного словаря")
        guard let tx = parsed else { return }

        XCTAssertEqual(tx.id,           101)
        XCTAssertEqual(tx.accountId,    202)
        XCTAssertEqual(tx.categoryId,   303)
        XCTAssertEqual(tx.amount,       Decimal(string: "123.45"))
        XCTAssertEqual(tx.comment,      "Test comment")
        XCTAssertEqual(tx.transactionDate, Date(timeIntervalSince1970: 1_600_000_000))
        XCTAssertEqual(tx.createdAt,       Date(timeIntervalSince1970: 1_600_000_100))
        XCTAssertEqual(tx.updatedAt,       Date(timeIntervalSince1970: 1_600_000_200))
    }

    func testParseInvalidJSONObject() throws {
        // отсутствуют нужные поля
        let badDict: [String: Any] = ["foo": "bar"]
        let parsed = Transaction.parse(jsonObject: badDict)
        XCTAssertNil(parsed, "parse(jsonObject:) должен возвращать nil для некорректного словаря")
    }

    func testJsonObjectRoundTrip() throws {
        // исходный Transaction
        let original = Transaction(
            id: 555,
            accountId: 666,
            categoryId: 777,
            amount: Decimal(string: "999.99")!,
            transactionDate: Date(timeIntervalSince1970: 1_700_000_000),
            comment: nil,
            createdAt:       Date(timeIntervalSince1970: 1_700_000_100),
            updatedAt:       Date(timeIntervalSince1970: 1_700_000_200)
        )

        // сериализуем в Foundation + обратно
        let raw = original.jsonObject
        let parsedOptional = Transaction.parse(jsonObject: raw)

        XCTAssertNotNil(parsedOptional, "Round-trip parse/jsonObject вернул nil")
        guard let parsed = parsedOptional else { return }

        // теперь можно сравнить сам Transaction
        XCTAssertEqual(parsed, original,
                       "Round-trip parse/jsonObject должен дать точно такой же Transaction")
    }
}
