//
//  FinanceAppApp.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.06.2025.
//

import SwiftUI
import SwiftData

@main
struct FinanceAppApp: App {
    @StateObject private var uiEvents = UIEvents()
    @StateObject private var services = ServicesContainer()
    @State private var isSplashFinished = false

    var body: some Scene {
        WindowGroup {
            if isSplashFinished {
                ContentView()
                    .environmentObject(uiEvents)
                    .task {
                        try? await DataMigrationManager.migrateIfNeeded()
                    }
                    .environmentObject(services)
                    .environmentObject(services.network)
            } else {
                SplashView {
                    withAnimation(.easeOut) {
                        isSplashFinished = true
                    }
                }
            }
        }
    }
}
