//
//  PriceChip.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI

/// Muestra un precio formateado con el estilo monetario de InvestFlow.
/// currencyCode: "USD", "PEN", etc.
public struct PriceChip: View {
    public let price: Decimal
    public let currencyCode: String
    public var size: ChipSize

    public enum ChipSize {
        case regular, large
        public var font: Font {
            switch self {
            case .regular: return .ifPrice
            case .large:   return .ifPriceLarge
            }
        }
    }

    public init(price: Decimal, currencyCode: String, size: ChipSize = .regular) {
        self.price = price
        self.currencyCode = currencyCode
        self.size = size
    }

    public var body: some View {
        Text(formatted)
            .font(size.font)
            .foregroundStyle(.primary)
            .monospacedDigit()
    }

    // Static: created once for the process lifetime, not per render. `currencyCode` is
    // reassigned per call since it varies by instance; safe because View members are
    // implicitly MainActor-isolated (single-threaded, no reentrancy within this call).
    @MainActor private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    private var formatted: String {
        Self.currencyFormatter.currencyCode = currencyCode
        return Self.currencyFormatter.string(from: price as NSDecimalNumber) ?? "-"
    }
}

#Preview {
    VStack(spacing: 12) {
        PriceChip(price: Decimal(string: "189.45")!, currencyCode: "USD")
        PriceChip(price: Decimal(string: "67420.00")!, currencyCode: "USD", size: .large)
    }
    .padding()
}
