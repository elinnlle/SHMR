//
//  Category.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Bool

    var direction: Direction {
        isIncome ? .income : .outcome
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }

    init(id: Int, name: String, emoji: Character, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id        = try container.decode(Int.self, forKey: .id)
        name      = try container.decode(String.self, forKey: .name)
        let emj   = try container.decode(String.self, forKey: .emoji)
        guard let first = emj.first else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji,
                in: container,
                debugDescription: "Emoji string is empty"
            )
        }
        emoji     = first
        isIncome  = try container.decode(Bool.self, forKey: .isIncome)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,       forKey: .id)
        try container.encode(name,     forKey: .name)
        try container.encode(String(emoji), forKey: .emoji)
        try container.encode(isIncome, forKey: .isIncome)
    }
}
