//
//  BalanceHistoryChartView.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 20.07.2025.
//

import SwiftUI
import Charts

// Значение баланса на дату
struct BalancePoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    var yValue: Double {
        (amount as NSDecimalNumber).doubleValue
    }
}

enum ChartPeriod: String, CaseIterable, Identifiable {
    case day   = "Дни"
    case month = "Месяцы"
    var id: Self { self }
}

struct BalanceHistoryChartView: View {
    let points: [BalancePoint]
    let period: ChartPeriod
    @State private var selected: BalancePoint?

    private var maxAbsValue: Double {
        points.map { abs($0.yValue) }.max() ?? 0
    }

    // Собираем первые, последние и даты в периоде
    private var axisDates: [Date] {
        let dates = points.map(\.date)
        guard dates.count > 1 else { return dates }

        let first = dates.first!
        let last  = dates.last!

        let step = (period == .day) ? 7 : 12  // 7 дней или 12 месяцев по индексам
        let mids = stride(from: 0, to: dates.count, by: step)
            .map { dates[$0] }
            .dropFirst()
            .dropLast()
            .map { $0 }

        return [first] + mids + [last]
    }


    var body: some View {
        Chart {
            ForEach(points) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", abs(item.yValue))
                )
                .foregroundStyle(
                    item.amount < 0
                        ? Color("OrangeAccent")
                        : Color("AccentColor")
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                )
            }
        }
        .chartYScale(domain: 0...maxAbsValue)

        // Задаём подписи по оси X
        .chartXAxis {
            AxisMarks(values: axisDates) { value in
                if let d = value.as(Date.self) {
                    let isFirst = (d == axisDates.first)
                    let isLast  = (d == axisDates.last)

                    let anchor: UnitPoint = isFirst
                                          ? .topLeading
                                          : (isLast ? .topTrailing : .top)
                    let xOffset: CGFloat = isFirst
                                         ? -8                // сдвигаем первую дату левее
                                         : (isLast ? 8 : 0)  // сдвигаем последнюю правее

                    AxisValueLabel(anchor: anchor) {
                        Text(
                            d,
                            format: period == .day
                                ? .dateTime.day(.twoDigits).month(.twoDigits)
                                : .dateTime.month(.abbreviated).year(.defaultDigits)
                        )
                        .offset(x: xOffset, y: 0)
                    }
                }
            }
        }

        // Убираем подписи по оси Y
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisTick()
            }
        }
        // Убираем сетку графика
        .chartOverlay { proxy in
            GeometryReader { _ in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let date: Date = proxy.value(atX: value.location.x) {
                                    selected = points.min(by: {
                                        abs($0.date.timeIntervalSince(date)) <
                                        abs($1.date.timeIntervalSince(date))
                                    })
                                }
                            }
                            .onEnded { _ in selected = nil }
                    )
            }
        }
        // Tooltip по удержанию
        .overlay(alignment: .topLeading) {
            if let sel = selected {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sel.date,
                         format: period == .day
                                ? .dateTime.day().month().year()
                                : .dateTime.month().year()
                    )
                    .font(.caption).foregroundStyle(.secondary)
                    Text(sel.amount,
                         format: .number.precision(.fractionLength(2)))
                    .font(.caption).bold()
                }
                .padding(6)
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 8))
                .offset(x: -6, y: -11)
            }
        }
        .animation(.easeInOut, value: points)
    }
}
