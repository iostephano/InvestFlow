//
//  PositionRowView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct PositionRowView: View {

    let position: Position

    var body: some View {
        HStack(spacing: 12) {
            InstrumentLogoView(
                instrumentID: position.instrumentID,
                instrumentType: position.instrumentType,
                size: 44,
                tintColor: .ifBlue
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(position.instrumentID)
                    .font(.ifHeadline)
                Text(formattedQuantity)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                PriceChip(price: position.marketValue, currencyCode: "USD")
                PLBadge(
                    absoluteValue: position.unrealizedPL,
                    percent:       position.unrealizedPLPercent
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Formateador

    // static: se crea una sola vez durante la vida del proceso, no en cada render.
    @MainActor private static let quantityFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 8
        f.numberStyle = .decimal
        return f
    }()

    private var formattedQuantity: String {
        let qty = Self.quantityFormatter.string(from: position.quantity as NSDecimalNumber) ?? "-"
        return "\(qty) \(position.unitLabel)"
    }
}
