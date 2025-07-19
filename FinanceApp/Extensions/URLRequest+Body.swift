//
//  URLRequest+Body.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

extension URLRequest {
    mutating func setJSONBody<T: Encodable>(_ body: T,
                                            encoder: JSONEncoder = .init()) throws {
        do {
            httpBody = try encoder.encode(body)
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw NetworkError.encoding(error)
        }
    }
}
