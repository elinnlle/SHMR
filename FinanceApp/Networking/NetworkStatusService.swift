//
//  NetworkStatusService.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import Network
import Combine

@MainActor
final class NetworkStatusService: ObservableObject {
    @Published private(set) var isOnline = true
    
    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "NetworkStatus")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
}
