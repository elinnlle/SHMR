//
//  NetworkError.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case statusCode(Int)
    case decoding(Error)
    case encoding(Error)
    case noData
    case url(URLError)

    var errorDescription: String? {
        switch self {
        case .statusCode(let code): return "Сервер вернул код \(code)"
        case .decoding:            return "Не удалось разобрать ответ сервера"
        case .encoding:            return "Не удалось подготовить запрос"
        case .noData:              return "Пустой ответ сервера"
        case .url(let err):        return err.localizedDescription
        }
    }
}
