//
//  CalculatePLUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Resumen de P&L del portafolio — resultado del CalculatePLUseCase.
public struct PLSummary: Sendable {
    public let totalMarketValue: Decimal
    public let totalCostBasis: Decimal
    public let totalUnrealizedPL: Decimal
    public let totalUnrealizedPLPercent: Decimal
    public let totalPortfolioValue: Decimal
    public let cashBalance: Decimal
    public let positionCount: Int
    public let isProfit: Bool

    /// Posición con mayor ganancia absoluta, si existe.
    public let bestPosition: Position?
    /// Posición con mayor pérdida absoluta, si existe.
    public let worstPosition: Position?
}

/// UseCase de cálculo de P&L. Puro: no accede a red ni almacenamiento.
/// Desacopla la Presentation de la estructura interna de Portfolio.
public struct CalculatePLUseCase: Sendable {

    public init() {}

    public func execute(portfolio: Portfolio) -> PLSummary {
        let positions = portfolio.positions
        let best  = positions.max { $0.unrealizedPL < $1.unrealizedPL }
        let worst = positions.min { $0.unrealizedPL < $1.unrealizedPL }

        return PLSummary(
            totalMarketValue:         portfolio.totalMarketValue,
            totalCostBasis:           portfolio.totalCostBasis,
            totalUnrealizedPL:        portfolio.totalUnrealizedPL,
            totalUnrealizedPLPercent: portfolio.totalUnrealizedPLPercent,
            totalPortfolioValue:      portfolio.totalPortfolioValue,
            cashBalance:              portfolio.cashBalance,
            positionCount:            positions.count,
            isProfit:                 portfolio.isProfit,
            bestPosition:             best,
            worstPosition:            worst.flatMap { $0.unrealizedPL < .zero ? $0 : nil }
        )
    }
}
