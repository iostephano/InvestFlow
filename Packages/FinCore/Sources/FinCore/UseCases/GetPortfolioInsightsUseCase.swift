//
//  GetPortfolioInsightsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetPortfolioInsightsUseCase: Sendable {

    public init() {}

    public func execute(portfolio: Portfolio, breakdown: PortfolioBreakdown) -> PortfolioInsights {
        let score     = diversificationScore(breakdown)
        let risk      = riskLevel(breakdown)
        let topPos    = portfolio.positions.max { $0.marketValue < $1.marketValue }
        let topPct    = topHoldingPercent(topPos, totalMarket: portfolio.totalMarketValue)

        return PortfolioInsights(
            diversificationScore: score,
            riskLevel:            risk,
            topHolding:           topPos,
            topHoldingPercent:    topPct,
            suggestedPortfolios:  Self.knownPortfolios
        )
    }

    private func diversificationScore(_ breakdown: PortfolioBreakdown) -> Int {
        let typeCount = breakdown.allocations.count
        let maxConc   = breakdown.allocations.map(\.percent).max() ?? .zero
        var score = min(75, typeCount * 25)
        if maxConc < 50 { score += 15 }
        if maxConc < 35 { score += 10 }
        return min(100, score)
    }

    private func riskLevel(_ breakdown: PortfolioBreakdown) -> RiskLevel {
        let cryptoPct = breakdown.allocations
            .first { $0.id == InstrumentType.crypto.rawValue }?.percent ?? .zero
        if cryptoPct > 30 { return .aggressive }
        if cryptoPct > 10 { return .moderate }
        return .conservative
    }

    private func topHoldingPercent(_ position: Position?, totalMarket: Decimal) -> Decimal {
        guard let pos = position, totalMarket > .zero else { return .zero }
        var raw = (pos.marketValue / totalMarket) * 100
        var r   = Decimal()
        NSDecimalRound(&r, &raw, 1, .plain)
        return r
    }

    public static let knownPortfolios: [SuggestedPortfolio] = [
        SuggestedPortfolio(
            id:                    "sp_growth",
            name:                  "Crecimiento Global",
            description:           "ETFs de mercados desarrollados con sesgo tecnológico.",
            expectedReturnPercent: 12.5,
            riskLevel:             .moderate
        ),
        SuggestedPortfolio(
            id:                    "sp_income",
            name:                  "Renta Fija Plus",
            description:           "Bonos corporativos y dividendos con flujo de caja estable.",
            expectedReturnPercent: 7.2,
            riskLevel:             .conservative
        ),
        SuggestedPortfolio(
            id:                    "sp_latam",
            name:                  "LATAM Emergente",
            description:           "Exposición a mercados emergentes latinoamericanos.",
            expectedReturnPercent: 18.0,
            riskLevel:             .aggressive
        )
    ]
}
