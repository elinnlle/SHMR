//
//  Transaction+CSV.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

extension Transaction {

    // Заголовок CSV-файла
    static var csvHeader: String {
        "id,accountId,categoryId,amount,transactionDate,comment,createdAt,updatedAt"
    }

    // Одна строка CSV
    var csvLine: String {
        // Экранируем кавычки
        let safeComment = comment?
            .replacingOccurrences(of: "\"", with: "\"\"") ?? ""
        // ISO-8601 форматор
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let txDateStr   = iso.string(from: transactionDate)
        let createdStr  = iso.string(from: createdAt)
        let updatedStr  = iso.string(from: updatedAt)

        return """
        \(id),\
        \(accountId),\
        \(categoryId),\
        \(amount),\
        \(txDateStr),\
        \"\(safeComment)\",\
        \(createdStr),\
        \(updatedStr)
        """
    }

    // Парсинг одной CSV-строки (без header) в Transaction
    static func parse(csvLine: String) -> Transaction? {
        var fields: [String] = []
        var current = ""
        var insideQuotes = false

        for char in csvLine {
            if char == "\"" {
                insideQuotes.toggle()
                continue
            }
            if char == "," && !insideQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)

        guard fields.count == 8,
              let id          = Int(fields[0]),
              let accountId   = Int(fields[1]),
              let categoryId  = Int(fields[2]),
              let amount      = Decimal(string: fields[3])
        else {
            return nil
        }

        // Даты
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let txDate    = iso.date(from: fields[4]),
              let createdAt = iso.date(from: fields[6]),
              let updatedAt = iso.date(from: fields[7])
        else {
            return nil
        }

        // Разворачиваем экранирование
        let rawComment = fields[5].replacingOccurrences(of: "\"\"", with: "\"")
        let comment: String? = rawComment.isEmpty ? nil : rawComment

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            comment: comment,
            transactionDate: txDate,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // Парсинг всего CSV-текста (с header) в массив Transaction
    static func parse(csvText: String) -> [Transaction] {
        let lines = csvText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        return lines
            .dropFirst()
            .compactMap(parse(csvLine:))
    }
}

