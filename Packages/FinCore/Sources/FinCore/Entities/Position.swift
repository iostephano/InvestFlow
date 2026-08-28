//
//  Position.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public struct Position: Identifiable, Sendable {
    public let id: String
    public let instrumentID: String
    public let instrumentType: InstrumentType
    public let quantity: Decimal
    public let averageCostBasis: Decimal
    public let currentPrice: Decimal

    public var unitLabel: String {
        switch instrumentType {
        case .crypto:    return "unidades"
        case .stock:     return "acciones"
        case .etf:       return "participaciones"
        case .portfolio: return "cuotas"
        }
    }

    public init(
        instrumentID: String,
        instrumentType: InstrumentType = .stock,
        quantity: Decimal,
        averageCostBasis: Decimal,
        currentPrice: Decimal
    ) {
        self.id = instrumentID
        self.instrumentID = instrumentID
        self.instrumentType = instrumentType
        self.quantity = quantity
        self.averageCostBasis = averageCostBasis
        self.currentPrice = currentPrice
    }
    
    // MARK: - Cálculos de P&L

    /// Valor actual a precio de mercado (mark-to-market).
    public var marketValue: Decimal {
        currentPrice * quantity
    }

    public var costBasis: Decimal {
        averageCostBasis * quantity
    }

    /// P&L no realizado en términos absolutos.
    public var unrealizedPL: Decimal {
        marketValue - costBasis
    }

    /// P&L no realizado como porcentaje, redondeado a 2 decimales.
    public var unrealizedPLPercent: Decimal {
        guard costBasis > .zero else { return .zero }
        let rawPercent = (unrealizedPL / costBasis) * 100
        var result = rawPercent
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, 2, .plain)
        return rounded
    }

    public var isProfit: Bool {
        unrealizedPL >= .zero
    }
}
