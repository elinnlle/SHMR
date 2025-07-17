//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

final class TransactionsService: TransactionsServiceProtocol {

    private let client: NetworkClient
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    func transactions(
        for accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)

        let startStr = df.string(from: startDate)
        let endStr   = df.string(from: endDate)

        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = "shmr-finance.ru"
        comps.path   = "/api/v1/transactions/account/\(accountId)/period"
        comps.queryItems = [
            URLQueryItem(name: "startDate", value: startStr),
            URLQueryItem(name: "endDate",   value: endStr)
        ]

        guard let url = comps.url else {
            throw URLError(.badURL)
        }

        let relativePath = url.absoluteString
            .replacingOccurrences(of: "https://shmr-finance.ru/api/v1/", with: "")

        return try await client.request(
            relativePath,
            method: .get,
            body: Optional<EmptyBody>.none
        )
    }

    func create(_ tx: Transaction) async throws {
        // Собираем тело запроса
        let absAmount = tx.amount < 0
            ? tx.amount.magnitude.description
            : tx.amount.description
        
        let req = TransactionRequest(
            accountId: tx.accountId,
            categoryId: tx.categoryId,
            amount: absAmount,
            transactionDate: isoFormatter.string(from: tx.transactionDate),
            comment: tx.comment ?? ""
        )

        // Логируем запрос
        let url = "transactions"
        let encoder = JSONEncoder()
        let data = try encoder.encode(req)
        if let json = String(data: data, encoding: .utf8) {
            print("POST https://shmr-finance.ru/api/v1/\(url)\nBody: \(json)")
        }
         
        // Отправляем и разбираем полноценный объект Transaction из ответа
        let created: Transaction = try await client.request(
            url,
            method: .post,
            body: req
        )
        // Логируем ответ
        print("Response (201): \(created)")
    }

    func update(_ tx: Transaction) async throws {
        let req = TransactionRequest(
            accountId: tx.accountId,
            categoryId: tx.categoryId,
            amount: tx.amount.description,
            transactionDate: isoFormatter.string(from: tx.transactionDate),
            comment: tx.comment
        )
        _ = try await client.request(
            "transactions/\(tx.id)",
            method: .put,
            body: req
        ) as EmptyResponse
    }

    func delete(id: Int) async throws {
        let path = "transactions/\(id)"
        print("DELETE https://shmr-finance.ru/api/v1/\(path)")
        do {
            // Если сервер возвращает пустое тело — мы всё равно пробуем распарсить EmptyResponse
            _ = try await client.request(
                path,
                method: .delete,
                body: Optional<EmptyBody>.none
            ) as EmptyResponse
            print("Response: deleted transaction \(id) — OK")
        } catch {
            // Ловим и логируем любую ошибку (например, приходящий от сервера JSON с вложенным `account`)
            print("Ignore non‑fatal error: \(error)")
        }
    }
}
