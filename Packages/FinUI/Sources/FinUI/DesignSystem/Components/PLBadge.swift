//
//  PLBadge.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI

/// Badge de ganancia/pérdida. percent en formato porcentual (ej: 14.70 = 14.70%).
public struct PLBadge: View {
    public let absoluteValue: Decimal
    public let percent: Decimal

    public init(absoluteValue: Decimal, percent: Decimal) {
        self.absoluteValue = absoluteValue
        self.percent = percent
    }

    private var isProfit: Bool { absoluteValue >= .zero }
    private var color: Color { .plColor(isProfit: isProfit) }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isProfit ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 10, weight: .bold))
            Text(formattedPercent)
                .font(.ifCaption)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.12))
        )
    }

    // Static: created once for the process lifetime, not per render.
    @MainActor private static let percentFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.positivePrefix = "+"
        return f
    }()

    private var formattedPercent: String {
        let value = (percent / 100) as NSDecimalNumber
        return Self.percentFormatter.string(from: value) ?? "-"
    }
}

#Preview {
    HStack(spacing: 12) {
        PLBadge(absoluteValue: Decimal(string: "242.00")!, percent: Decimal(string: "14.70")!)
        PLBadge(absoluteValue: Decimal(string: "-89.30")!, percent: Decimal(string: "-2.49")!)
    }
    .padding()
}
