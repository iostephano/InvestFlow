//
//  CandlestickChartView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Charts
import FinCore
import FinUI
import SwiftUI

enum ChartPeriod: String, CaseIterable, Identifiable {
    case day   = "1D"
    case week  = "1S"
    case month = "1M"
    case year  = "1A"

    var id: String { rawValue }
}

private struct PricePoint: Identifiable {
    let id: Int
    let date: Date
    let price: Double
}

/// Gráfico de precios históricos simulados. Transición suave desde open → close
/// usando random walk determinista basado en el instrumentID.
struct CandlestickChartView: View {

    let quote: Quote
    var period: ChartPeriod = .day

    private var isPositive: Bool { quote.change >= .zero }
    private var lineColor: Color { .plColor(isProfit: isPositive) }

    /// Historial simulado memoizado. `generateHistory` es un random walk determinista
    /// O(n); recomputarlo en cada pasada de `body` (se leía 3×: una por `Chart`, una
    /// por cada `minY`/`maxY`) es un desperdicio. Solo depende de la identidad/precio/cambio
    /// de la cotización y del período seleccionado, así que se regenera únicamente cuando
    /// cambia `regenerationKey`.
    @State private var dataPoints: [PricePoint] = []

    private var regenerationKey: String {
        "\(quote.id)|\(quote.price)|\(quote.change)|\(period.rawValue)"
    }

    private var minY: Double { (dataPoints.map(\.price).min() ?? 0) * 0.997 }
    private var maxY: Double { (dataPoints.map(\.price).max() ?? 1) * 1.003 }

    var body: some View {
        Chart(dataPoints) { point in
            AreaMark(
                x: .value("t", point.date),
                yStart: .value("base", minY),
                yEnd:   .value("price", point.price)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [lineColor.opacity(0.25), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("t", point.date),
                y: .value("price", point.price)
            )
            .foregroundStyle(lineColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }
        .chartYScale(domain: minY ... maxY)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .onChange(of: regenerationKey, initial: true) { _, _ in
            dataPoints = generateHistory(quote: quote, period: period)
        }
    }

    // MARK: - Historial simulado

    private func generateHistory(quote: Quote, period: ChartPeriod) -> [PricePoint] {
        let current  = NSDecimalNumber(decimal: quote.price).doubleValue
        let change   = NSDecimalNumber(decimal: quote.change).doubleValue
        let openPrice = current - change

        let now = Date()
        let calendar = Calendar.current
        let (count, start): (Int, Date) = {
            switch period {
            case .day:   return (78,  calendar.date(byAdding: .hour,  value: -7,  to: now)!)
            case .week:  return (70,  calendar.date(byAdding: .day,   value: -7,  to: now)!)
            case .month: return (60,  calendar.date(byAdding: .month, value: -1,  to: now)!)
            case .year:  return (52,  calendar.date(byAdding: .year,  value: -1,  to: now)!)
            }
        }()

        let step = now.timeIntervalSince(start) / Double(count)

        // LCG determinista sembrado desde quote.id para renders reproducibles
        var seed = UInt64(bitPattern: Int64(quote.id.hashValue))
        func rand() -> Double {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Double(seed >> 33) / Double(1 << 31)
        }

        var price = openPrice
        var points: [PricePoint] = []

        for i in 0 ... count {
            let date  = start.addingTimeInterval(step * Double(i))
            let nudge = (current - price) * 0.06
            let noise = (rand() - 0.5) * current * 0.005
            price += nudge + noise
            if i == count { price = current }
            points.append(PricePoint(id: i, date: date, price: max(price, 0.001)))
        }

        return points
    }
}

#Preview {
    CandlestickChartView(
        quote: Quote(
            id: "AAPL",
            price: Decimal(string: "189.45")!,
            change: Decimal(string: "2.30")!,
            changePercent: Decimal(string: "1.23")!,
            volume: 52_000_000
        ),
        period: .day
    )
    .frame(height: 200)
    .padding()
}
