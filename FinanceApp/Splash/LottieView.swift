//
//  LottieView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 21.07.2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let completion: (() -> Void)?

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        view.play { finished in
            if finished { completion?() }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) { }
}

