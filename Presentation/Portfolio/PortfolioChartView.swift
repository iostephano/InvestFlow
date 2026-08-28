//
//  PortfolioChartView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Charts
import FinCore
import SwiftUI
import FinUI

struct PortfolioChartView: View {

    let breakdown: PortfolioBreakdown

    // MARK: - Datos del gráfico

    private struct Slice: Identifiable {
        let id: String
        let label: String
        let amount: Double
        let color: Color
    }

    private var slices: [Slice] {
        var result: [Slice] = []
        if breakdown.cashValue > .zero {
            result.append(Slice(
                id: "cash", label: "Efectivo",
                amount: doubleValue(breakdown.cashValue),
                color: .ifBlue
            ))
        }
        for alloc in breakdown.allocations where alloc.value > .zero {
            result.append(Slice(
                id: alloc.id, label: alloc.label,
                amount: doubleValue(alloc.value),
                color: allocationColor(alloc.id)
            ))
        }
        return result
    }

    // MARK: - Cuerpo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Distribución")
                .font(.ifHeadline)

            HStack(alignment: .center, spacing: 24) {
                donutChart
                    .frame(width: 140, height: 140)

                legend
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ifSurface(.glass, radius: IFRadius.md)
    }

    // MARK: - Dona

    private var donutChart: some View {
        Chart(slices) { slice in
            SectorMark(
                angle: .value(slice.label, slice.amount),
                innerRadius: .ratio(0.58),
                angularInset: 1.5
            )
            .foregroundStyle(slice.color)
            .cornerRadius(3)
        }
    }

    // MARK: - Leyenda

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(slices) { slice in
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(slice.color)
                        .frame(width: 12, height: 12)
                    Text(slice.label)
                        .font(.ifCaption)
                    Spacer()
                    Text(pctString(for: slice.id))
                        .font(.ifCaption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }
            }
        }
    }

    // MARK: - Auxiliares

    private func allocationColor(_ id: String) -> Color {
        switch InstrumentType(rawValue: id) {
        case .stock:     return .ifGreen
        case .etf:       return Color.orange
        case .crypto:    return Color.purple
        case .portfolio: return Color.teal
        default:         return .ifSecondary
        }
    }

    private func pctString(for id: String) -> String {
        let pct: Decimal
        if id == "cash" {
            pct = breakdown.cashPercent
        } else {
            pct = breakdown.allocations.first { $0.id == id }?.percent ?? .zero
        }
        let d = Double(truncating: pct as NSDecimalNumber)
        return String(format: "%.1f%%", d)
    }

    private func doubleValue(_ d: Decimal) -> Double {
        Double(truncating: d as NSDecimalNumber)
    }
}
