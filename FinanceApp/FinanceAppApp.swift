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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(uiEvents)
        }
    }
}
