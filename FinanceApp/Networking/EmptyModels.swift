//
//  EmptyModels.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import Foundation

/// Используем, когда в request нет тела
struct EmptyBody: Encodable {}

/// Используем, когда в ответе нет тела
struct EmptyResponse: Decodable {}
