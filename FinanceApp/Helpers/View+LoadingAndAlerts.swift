//
//  View+LoadingAndAlerts.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 15.07.2025.
//

import SwiftUI

extension View {
    func withLoadAndAlerts() -> some View {
        modifier(LoadAndAlertModifier())
    }
}

private struct LoadAndAlertModifier: ViewModifier {
    @EnvironmentObject private var ui: UIEvents

    func body(content: Content) -> some View {
        content
            .overlay {
                if ui.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .alert(item: $ui.alert) { alertData in
                Alert(
                    title: Text(alertData.title),
                    message: Text(alertData.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

