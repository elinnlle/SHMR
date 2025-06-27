//
//  SpoilerEffect.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 27.06.2025.
//

import SwiftUI
import UIKit

// MARK: - UIView с CAEmitterLayer

final class SpoilerParticleView: UIView {

    override class var layerClass: AnyClass { CAEmitterLayer.self }
    override var layer: CAEmitterLayer { super.layer as! CAEmitterLayer }

    override init(frame: CGRect) {
        super.init(frame: frame); configureEmitter()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder);  configureEmitter()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = .init(x: bounds.midX, y: bounds.midY)
        layer.emitterSize = bounds.size
    }

    private func configureEmitter() {
        let cell = CAEmitterCell()
        cell.contents      = Self.speckle.cgImage
        cell.contentsScale = 1.8
        cell.emissionRange = .pi * 2
        cell.lifetime      = 1
        cell.scale         = 0.5
        cell.velocityRange = 20
        cell.alphaRange    = 1
        cell.birthRate     = 4_000

        layer.emitterShape = .rectangle
        layer.emitterCells = [cell]
        layer.birthRate    = 0 // стартуем «спойлер» скрытым
    }

    // 2×2 - пиксельное белое изображение для частиц
    private static let speckle: UIImage = {
        UIGraphicsImageRenderer(size: .init(width: 2, height: 2))
            .image { ctx in
                UIColor.white.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
            }
    }()
}

struct SpoilerView: UIViewRepresentable {
    var isOn: Bool

    func makeUIView(context: Context) -> SpoilerParticleView { SpoilerParticleView() }

    func updateUIView(_ uiView: SpoilerParticleView, context: Context) {
        if isOn { uiView.layer.beginTime = CACurrentMediaTime() } // перезапуск анимации
        uiView.layer.birthRate = isOn ? 1 : 0
    }
}

private struct SpoilerModifier: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isOn ? 0 : 1)                 // прячем оригинальный контент
            .overlay { SpoilerView(isOn: isOn) }   // и показываем частицы
            .animation(.easeInOut(duration: 0.25), value: isOn)
    }
}

extension View {
    // Применяет «спойлер». Нажатием по содержимому тоже можно переключать состояние
    func spoiler(isOn: Binding<Bool>) -> some View {
        modifier(SpoilerModifier(isOn: isOn.wrappedValue))
            .onTapGesture { isOn.wrappedValue.toggle() }
    }
}
