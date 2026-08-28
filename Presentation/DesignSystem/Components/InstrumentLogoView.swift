//
//  InstrumentLogoView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore

private let supportedLogoAssets: Set<String> = ["aapl", "tsla", "btc", "eth", "spy", "qqq"]

struct InstrumentLogoView: View {
    let instrumentID: String
    let instrumentType: InstrumentType
    let size: CGFloat
    let tintColor: Color
    var cornerRadius: CGFloat = 10
    var backgroundOpacity: Double = 0.12
    var logoScale: CGFloat = 0.60

    private var logoSize: CGFloat { size * logoScale }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(tintColor.opacity(backgroundOpacity))

            if let key = logoKey {
                Image(key)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
            } else {
                Image(systemName: fallbackIcon)
                    .font(.system(size: logoSize, weight: .medium))
                    .foregroundStyle(tintColor)
            }
        }
        .frame(width: size, height: size)
    }

    private var logoKey: String? {
        let key = instrumentID.lowercased()
        return supportedLogoAssets.contains(key) ? key : nil
    }

    private var fallbackIcon: String {
        switch instrumentType {
        case .stock:     return "building.columns"
        case .etf:       return "chart.pie"
        case .crypto:    return "bitcoinsign.circle"
        case .portfolio: return "briefcase"
        }
    }
}
