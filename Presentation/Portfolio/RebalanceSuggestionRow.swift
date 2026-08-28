//
//  RebalanceSuggestionRow.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct RebalanceSuggestionRow: View {

    let suggestion: RebalanceSuggestion

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(actionColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: actionIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(actionColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.instrumentID)
                    .font(.ifHeadline)
                Text(actionLabel)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatWeight(suggestion.currentWeight))
                    .font(.ifBody)
                    .fontWeight(.medium)
                Text("→ \(formatWeight(suggestion.targetWeight))")
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Auxiliares de presentación

    private var actionColor: Color {
        suggestion.suggestedAction == .buy ? .ifGreen : .ifRed
    }

    private var actionIcon: String {
        suggestion.suggestedAction == .buy ? "arrow.down.to.line" : "arrow.up.to.line"
    }

    private var actionLabel: String {
        suggestion.suggestedAction == .buy ? "Infraponderar → Comprar más" : "Sobreponderar → Reducir posición"
    }

    // MARK: - Formateador

    @MainActor private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.minimumFractionDigits = 1
        f.maximumFractionDigits = 1
        return f
    }()

    private func formatWeight(_ weight: Decimal) -> String {
        Self.weightFormatter.string(from: weight as NSDecimalNumber) ?? "-"
    }
}
