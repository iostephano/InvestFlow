//
//  AssetBreakdownBar.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct AssetBreakdownBar: View {

    let breakdown: PortfolioBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Composición")
                .font(.ifHeadline)

            GeometryReader { geo in
                HStack(spacing: 3) {
                    bar(pct: breakdown.cashPercent, color: .ifBlue, total: geo.size.width)
                    ForEach(breakdown.allocations) { alloc in
                        bar(pct: alloc.percent, color: allocationColor(alloc.id), total: geo.size.width)
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 14)

            legendRow
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ifCard)
        .cornerRadius(16)
    }

    // MARK: - Segmento de barra

    @ViewBuilder
    private func bar(pct: Decimal, color: Color, total: CGFloat) -> some View {
        let w = segmentWidth(pct: pct, total: total)
        if w > 0 {
            Rectangle()
                .fill(color)
                .frame(width: w)
        }
    }

    private func segmentWidth(pct: Decimal, total: CGFloat) -> CGFloat {
        let d = Double(truncating: pct as NSDecimalNumber) / 100.0
        return max(0, CGFloat(d) * total)
    }

    // MARK: - Fila de leyenda

    private var legendRow: some View {
        HStack(spacing: 16) {
            legendItem(color: .ifBlue, label: "Efectivo", pct: breakdown.cashPercent)
            ForEach(breakdown.allocations) { alloc in
                legendItem(color: allocationColor(alloc.id), label: alloc.label, pct: alloc.percent)
            }
        }
    }

    private func legendItem(color: Color, label: String, pct: Decimal) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(label) \(pctString(pct))")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
        }
    }

    private func pctString(_ d: Decimal) -> String {
        String(format: "%.0f%%", Double(truncating: d as NSDecimalNumber))
    }

    private func allocationColor(_ id: String) -> Color {
        switch InstrumentType(rawValue: id) {
        case .stock:     return .ifGreen
        case .etf:       return Color.orange
        case .crypto:    return Color.purple
        case .portfolio: return Color.teal
        default:         return .ifSecondary
        }
    }
}
