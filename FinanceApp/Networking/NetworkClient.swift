//
//  NetworkClient.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

final class NetworkClient {

    // MARK: – Константы
    private let baseURL: URL = URL(string: "https://shmr-finance.ru/api/v1")!
    private let token: String   = "TOKEN"

    // MARK: – Инъекции
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .custom { decoder in
          let container = try decoder.singleValueContainer()
          let dateStr = try container.decode(String.self)
          let isoWithFraction = ISO8601DateFormatter()
          isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
          if let date = isoWithFraction.date(from: dateStr) { return date }
          let iso = ISO8601DateFormatter()
          iso.formatOptions = [.withInternetDateTime]
          if let date = iso.date(from: dateStr) { return date }
          throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot parse date: \(dateStr)"
          )
        }

    }

    // MARK: – Базовый метод
    @discardableResult
    func request<Body: Encodable, Response: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        body: Body? = nil,
        headers: [String: String] = [:]
    ) async throws -> Response {
        // Собираем URL
        let url: URL
        if let qIndex = path.firstIndex(of: "?") {
            let endpoint   = String(path[..<qIndex])
            let queryPart  = String(path[path.index(after: qIndex)...])
            let baseAndPath = baseURL.appendingPathComponent(endpoint)
            var comps = URLComponents(url: baseAndPath, resolvingAgainstBaseURL: false)!
            comps.percentEncodedQuery = queryPart
            guard let final = comps.url else {
                fatalError("Failed to build URL from \(baseAndPath) + ?\(queryPart)")
            }
            url = final
        } else {
            url = baseURL.appendingPathComponent(path)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // Тело
        if let body {
            try request.setJSONBody(body, encoder: encoder)
        }

        // Отправляем
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.statusCode(http.statusCode)
            }
            return try decoder.decode(Response.self, from: data)
        } catch let err as NetworkError {
            throw err
        } catch let err as URLError {
            throw NetworkError.url(err)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}

