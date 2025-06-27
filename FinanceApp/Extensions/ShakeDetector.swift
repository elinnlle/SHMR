//
//  ShakeDetector.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 24.06.2025.
//

import SwiftUI
import UIKit

struct ShakeDetector: UIViewRepresentable {
    let onShake: () -> Void

    func makeUIView(context: Context) -> ShakeUIView {
        let view = ShakeUIView()
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeUIView, context: Context) {
        uiView.onShake = onShake

        if uiView.window != nil, uiView.isFirstResponder == false {
            uiView.becomeFirstResponder()
        }
    }

    final class ShakeUIView: UIView {
        var onShake: () -> Void = { }

        override var canBecomeFirstResponder: Bool { true }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            // Становимся first-responder, как только попали в окно.
            DispatchQueue.main.async { [weak self] in
                _ = self?.becomeFirstResponder()
            }
        }

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            guard motion == .motionShake else { return }
            onShake()
        }
    }
}
