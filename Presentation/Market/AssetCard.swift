//
//  AssetCard.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct AssetCard: View {

    let item: MarketItem
    let onTap: () -> Void

    private var instrument: Instrument { item.instrument }
    private var quote: Quote           { item.quote }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    instrumentIcon
                    Spacer()
                    changeBadge
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(instrument.id)
                        .font(.ifHeadline)
                        .lineLimit(1)
                    Text(instrument.name)
                        .font(.ifCaption)
                        .foregroundStyle(.ifSecondary)
                        .lineLimit(1)
                }

                Text(priceFormatted)
                    .font(.ifPrice)
                    .monospacedDigit()
            }
            .padding(14)
            .frame(width: 150)
            .ifSurface(.glass, radius: IFRadius.md, shadow: IFShadow.none)
        }
        .buttonStyle(.ifCard)
    }

    // MARK: - Subvistas

    private var instrumentIcon: some View {
        InstrumentLogoView(
            instrumentID: instrument.id,
            instrumentType: instrument.type,
            size: 38,
            tintColor: typeColor,
            backgroundOpacity: 0.15,
            logoScale: 0.58
        )
    }

    private var changeBadge: some View {
        Text(changeFormatted)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(quote.isPositive ? Color.white : Color.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(quote.isPositive ? Color.ifGreen : Color.ifRed)
            )
    }

    // MARK: - Auxiliares

    // static: se crea una sola vez durante la vida del proceso, no en cada render. `currencyCode` y
    // `maximumFractionDigits` se reasignan en cada llamada porque varían por instrumento; es seguro
    // porque los miembros de View están implícitamente aislados a MainActor (un solo hilo, sin reentrada).
    @MainActor private static let priceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    private var priceFormatted: String {
        Self.priceFormatter.currencyCode = instrument.currency.rawValue
        Self.priceFormatter.maximumFractionDigits = instrument.type == .crypto ? 0 : 2
        return Self.priceFormatter.string(from: quote.price as NSDecimalNumber) ?? "-"
    }

    private var changeFormatted: String {
        let d = Double(truncating: quote.changePercent as NSDecimalNumber)
        return String(format: "%+.2f%%", d)
    }

    private var typeColor: Color { .ifBlue }

}
