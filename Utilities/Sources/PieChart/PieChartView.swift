//
//  PieChartView.swift
//  Utilities
//
//  Created by Эльвира Матвеенко on 19.07.2025.
//

import UIKit

@IBDesignable
public final class PieChartView: UIView {

    // MARK: –- Публичные данные
    public var entities: [PieChartEntity] = [] {
        didSet { setNeedsDisplay() }
    }

    // MARK: –- Константы
    private static let segmentColors: [UIColor] = [
        UIColor(red:   0x2A/255.0, green: 0xE8/255.0, blue: 0x81/255.0, alpha: 1), // 2AE881
        UIColor(red:   0xFC/255.0, green: 0xE3/255.0, blue: 0x00/255.0, alpha: 1), // FCE300
        UIColor(red:   0xFF/255.0, green: 0x5F/255.0, blue: 0x00/255.0, alpha: 1), // FF5F00
        UIColor(red:   0xFF/255.0, green: 0x37/255.0, blue: 0xBC/255.0, alpha: 1), // FF37BC
        UIColor(red:   0x6F/255.0, green: 0x5D/255.0, blue: 0xB7/255.0, alpha: 1), // 6F5DB7
        UIColor(red:   0x00/255.0, green: 0xBB/255.0, blue: 0xFF/255.0, alpha: 1), // 00BBFF
    ]
    private let lineWidthRatio: CGFloat = 0.12  // толщина
    private let font = UIFont.systemFont(ofSize: 10, weight: .regular)

    // MARK: –- Жизненный цикл
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    required init?(coder: NSCoder) { super.init(coder: coder); isOpaque = false }

    // MARK: –- Отрисовка
    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !entities.isEmpty else { return }

        let radius = min(rect.width, rect.height) / 2 * 0.9
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let lineWidth = radius * lineWidthRatio

        // Первые 5 элементов + «Остальные»
        let top5 = entities.prefix(5)
        let othersValue = entities.dropFirst(5).reduce(Decimal(0)) { $0 + $1.value }
        var drawingSet = Array(top5)
        if othersValue > 0 {
            drawingSet.append(.init(value: othersValue, label: "Остальные"))
        }

        // Подсчёт суммарного значения
        let total = drawingSet.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else { return }

        // Рисуем сегменты
        var startAngle = -CGFloat.pi / 2  // 12 часов
        for (index, entity) in drawingSet.enumerated() {
            let fraction = CGFloat((entity.value / total as NSDecimalNumber).doubleValue)
            let endAngle = startAngle + fraction * 2 * .pi

            ctx.setFillColor(Self.segmentColors[index].cgColor)
            let path = UIBezierPath()
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            path.addArc(withCenter: center,
                        radius: radius - lineWidth,
                        startAngle: endAngle,
                        endAngle: startAngle,
                        clockwise: false)
            path.close()
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            startAngle = endAngle
        }

        // Легенда в центре
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let legend = drawingSet.enumerated()
            .map { index, e -> NSAttributedString in
                let percent = e.value * 100 / total
                let text = String(format: "%.0f%% %@", NSDecimalNumber(decimal: percent).doubleValue, e.label)
                let attr = NSMutableAttributedString(string: text)
                attr.addAttribute(.foregroundColor,
                                  value: Self.segmentColors[index],
                                  range: NSRange(location: 0, length: attr.length))
                return attr
            }
            .reduce(into: NSMutableAttributedString()) { res, part in
                if res.length > 0 { res.append(NSAttributedString(string: "\n")) }
                res.append(part)
            }
        legend.addAttributes([.paragraphStyle: paragraph,
                              .font: font,
                              .foregroundColor: UIColor.label],
                             range: NSRange(location: 0, length: legend.length))

        let legendSize = legend.boundingRect(
            with: CGSize(width: radius*1.3, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).size
        let legendOrigin = CGPoint(x: center.x - legendSize.width/2,
                                   y: center.y - legendSize.height/2)
        legend.draw(in: CGRect(origin: legendOrigin, size: legendSize))
    }

    // MARK: –- Анимация смены данных
    public func setEntities(_ newValue: [PieChartEntity], animated: Bool) {
        guard animated else { entities = newValue; return }

        // группа: вращение + fade-out
        let rotateOut = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateOut.fromValue = 0
        rotateOut.toValue   = CGFloat.pi // 180°
        rotateOut.duration  = 0.4
        rotateOut.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue   = 0
        fadeOut.duration  = 0.4
        fadeOut.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let group1 = CAAnimationGroup()
        group1.animations = [rotateOut, fadeOut]
        group1.duration   = 0.4
        group1.isRemovedOnCompletion = false
        group1.fillMode = .forwards
        layer.add(group1, forKey: "out")

        // обновляем данные в самом конце первой фазы
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.entities = newValue
            self?.layer.removeAnimation(forKey: "out")

            // вторая фаза: вращаем вторые 180° + fade-in
            let rotateIn = CABasicAnimation(keyPath: "transform.rotation.z")
            rotateIn.fromValue = CGFloat.pi
            rotateIn.toValue   = 2 * CGFloat.pi // 360°
            rotateIn.duration  = 0.4
            rotateIn.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let fadeIn = CABasicAnimation(keyPath: "opacity")
            fadeIn.fromValue = 0
            fadeIn.toValue   = 1
            fadeIn.duration  = 0.4
            fadeIn.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let group2 = CAAnimationGroup()
            group2.animations = [rotateIn, fadeIn]
            group2.duration   = 0.4
            self?.layer.add(group2, forKey: "in")
        }
    }
}
