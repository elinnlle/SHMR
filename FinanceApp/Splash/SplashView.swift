//
//  SplashView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 21.07.2025.
//

import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            // сама Lottie‑анимация
            LottieView(animationName: "upload", completion: onFinished)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
        }
        .transaction { $0.disablesAnimations = true }
    }
}
