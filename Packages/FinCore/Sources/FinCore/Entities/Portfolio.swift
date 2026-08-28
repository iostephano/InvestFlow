//
//  Portfolio.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Agregado del portafolio completo de un usuario.
/// Consolida posiciones + cash para calcular métricas globales.
public struct Portfolio: Sendable {
    public let userID: String
    public let positions: [Position]
    public let cashBalance: Decimal
    public let currency: Currency
    public let updatedAt: Date

    // MARK: - Métricas calculadas

    public var totalMarketValue: Decimal {
        positions.reduce(.zero) { $0 + $1.marketValue }
    }

    public var totalCostBasis: Decimal {
        positions.reduce(.zero) { $0 + $1.costBasis }
    }

    public var totalUnrealizedPL: Decimal {
        totalMarketValue - totalCostBasis
    }

    public var totalUnrealizedPLPercent: Decimal {
        guard totalCostBasis > .zero else { return .zero }
        var raw = (totalUnrealizedPL / totalCostBasis) * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &raw, 2, .plain)
        return rounded
    }

    /// Valor total incluyendo cash disponible.
    public var totalPortfolioValue: Decimal {
        totalMarketValue + cashBalance
    }

    public var isProfit: Bool { totalUnrealizedPL >= .zero }
    public var hasPositions: Bool { !positions.isEmpty }

    public init(
        userID: String,
        positions: [Position],
        cashBalance: Decimal,
        currency: Currency,
        updatedAt: Date = Date()
    ) {
        self.userID = userID
        self.positions = positions
        self.cashBalance = cashBalance
        self.currency = currency
        self.updatedAt = updatedAt
    }
}
