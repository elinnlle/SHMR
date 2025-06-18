//
//  TransactionsFileCache.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import Foundation

final class TransactionsFileCache {

    private(set) var transactions: [Transaction] = []

    // Добавляет новую операцию, если её id ещё нет в кеше.
    func add(_ tx: Transaction) {
        guard !transactions.contains(where: { $0.id == tx.id }) else { return }
        transactions.append(tx)
    }

    // Удаляет операцию по идентификатору.
    func remove(id: Int) {
        transactions.removeAll { $0.id == id }
    }

    // Сохраняет весь кеш в файл по указанному URL.
    func save(to url: URL) throws {
        let jsonArray = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(
            withJSONObject: jsonArray,
            options: .prettyPrinted
        )
        try ioQueue.sync {
            try data.write(to: url, options: .atomic)
        }
    }

    // Загружает операции из файла по URL, объединяя их с текущими.
    func load(from url: URL) throws {
        // Если файла нет — просто выходим
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data)

        guard let jsonArray = raw as? [Any] else { return }

        // Парсим каждую запись в Transaction
        let loaded = jsonArray.compactMap(Transaction.parse(jsonObject:))
        
        // Отфильтровываем дубликаты по id
        let existingIds = Set(transactions.map(\.id))
        let unique = loaded.filter { !existingIds.contains($0.id) }
        
        transactions.append(contentsOf: unique)
    }

    private let ioQueue = DispatchQueue(label: "com.yourapp.finance.filecache")
}
