//
//  OfflineBanner.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        Text("Offline mode")
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(Color.red)
    }
}
