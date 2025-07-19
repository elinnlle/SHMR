//
//  NetworkStatusService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Foundation
import Network
import Combine

@MainActor
final class NetworkStatusService: ObservableObject {
    /// по-умолчанию считаем, что мы онлайн
    @Published private(set) var isOnline: Bool = true

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    init(requiredInterfaceType: NWInterface.InterfaceType? = nil) {
        // инициализируем монитор
        if let type = requiredInterfaceType {
            monitor = NWPathMonitor(requiredInterfaceType: type)
        } else {
            monitor = NWPathMonitor()
        }
        queue = DispatchQueue(label: "NetworkStatus")

        // запускаем монитор
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.handlePathUpdate(path)
            }
        }
        monitor.start(queue: queue)

        // сразу же делаем реальную проверку
        checkInternet { [weak self] alive in
            Task { @MainActor in
                guard let self = self else { return }
                self.isOnline = alive
                print("🌐 Initial internet reachability: \(alive ? "online" : "offline")")
            }
        }
    }

    @MainActor
    private func handlePathUpdate(_ path: NWPath) {
        let hasRoute = path.status == .satisfied
        print("🌐 Network path changed: \(hasRoute ? "satisfied" : "unsatisfied")")

        if hasRoute {
            // если есть маршрут — убедимся, что Интернет действительно доступен
            checkInternet { [weak self] alive in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isOnline = alive
                    print("🌐 Internet really is \(alive ? "online" : "offline")")
                }
            }
        } else {
            // нет маршрута — считаем оффлайн сразу
            isOnline = false
            print("🌐 No route → offline")
        }
    }

    // Проверка реального доступа в Интернет
    private func checkInternet(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://apple.com/favicon.ico") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { _, response, error in
            let ok = (error == nil) && (response as? HTTPURLResponse)?.statusCode == 200
            completion(ok)
        }.resume()
    }
}
