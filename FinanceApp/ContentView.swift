
//  ContentView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .environment(\.locale, Locale(identifier: "ru"))
    }
}

#Preview {
    ContentView()
}
