//
//  PortfolioInsightCard.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct PortfolioInsightCard: View {

    let insights: PortfolioInsights
    var onPortfolioTap: (SuggestedPortfolio) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            diversificationRow
            riskRow
            if let top = insights.topHolding {
                topHoldingRow(top)
            }
            suggestedSection
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ifSurface(.glass, radius: IFRadius.md, specularBorder: true)
    }

    // MARK: - Score de diversificación

    private var diversificationRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Diversificación")
                    .font(.ifHeadline)
                Spacer()
                Text("\(insights.diversificationScore)/100")
                    .font(.ifSubhead)
                    .fontWeight(.semibold)
                    .foregroundStyle(scoreColor)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.ifSecondary.opacity(0.15))
                    Capsule()
                        .fill(scoreColor)
                        .frame(width: geo.size.width * CGFloat(insights.diversificationScore) / 100)
                }
            }
            .frame(height: 8)
        }
    }

    private var scoreColor: Color {
        switch insights.diversificationScore {
        case 75...: return .ifGreen
        case 40...: return Color.orange
        default:    return .ifRed
        }
    }

    // MARK: - Nivel de riesgo

    private var riskRow: some View {
        HStack(spacing: 12) {
            Image(systemName: insights.riskLevel.icon)
                .font(.system(size: 20))
                .foregroundStyle(riskColor)
                .frame(width: 36, height: 36)
                .background(riskColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("Perfil de riesgo")
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                Text(insights.riskLevel.displayName)
                    .font(.ifBody)
                    .fontWeight(.semibold)
            }
        }
    }

    private var riskColor: Color {
        switch insights.riskLevel {
        case .conservative: return .ifGreen
        case .moderate:     return Color.orange
        case .aggressive:   return .ifRed
        }
    }

    // MARK: - Holding principal

    private func topHoldingRow(_ position: Position) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("Mayor posición")
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                Text("\(position.instrumentID) · \(pctString(insights.topHoldingPercent)) del portafolio")
                    .font(.ifBody)
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Portafolios sugeridos

    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Portafolios sugeridos")
                .font(.ifHeadline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insights.suggestedPortfolios) { portfolio in
                        Button {
                            onPortfolioTap(portfolio)
                        } label: {
                            SuggestedPortfolioCard(portfolio: portfolio)
                        }
                        .buttonStyle(.ifCard)
                    }
                }
            }
        }
    }

    private func pctString(_ d: Decimal) -> String {
        String(format: "%.1f%%", Double(truncating: d as NSDecimalNumber))
    }
}

// MARK: - Tarjeta de portafolio sugerido

private struct SuggestedPortfolioCard: View {
    let portfolio: SuggestedPortfolio

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: portfolio.riskLevel.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(riskColor)
                Spacer()
                Text("+\(returnString)")
                    .font(.ifCaption)
                    .fontWeight(.bold)
                    .foregroundStyle(.ifGreen)
                    .monospacedDigit()
            }

            Text(portfolio.name)
                .font(.ifBody)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(portfolio.description)
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(width: 180)
        .ifSurface(.opaque, radius: IFRadius.sm, shadow: IFShadow.none)
        .overlay(
            RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
                .strokeBorder(riskColor.opacity(0.35), lineWidth: 0.5)
        )
    }

    private var riskColor: Color {
        switch portfolio.riskLevel {
        case .conservative: return .ifGreen
        case .moderate:     return Color.orange
        case .aggressive:   return .ifRed
        }
    }

    private var returnString: String {
        String(
            format: "%.1f%% / año",
            Double(truncating: portfolio.expectedReturnPercent as NSDecimalNumber)
        )
    }
}
