//
//  GetPortfolioBreakdownUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetPortfolioBreakdownUseCase: Sendable {

    public init() {}

    public func execute(portfolio: Portfolio) -> PortfolioBreakdown {
        let totalValue = portfolio.totalPortfolioValue
        guard totalValue > .zero else { return .empty }

        var byType: [InstrumentType: Decimal] = [:]
        for position in portfolio.positions {
            byType[position.instrumentType, default: .zero] += position.marketValue
        }

        let investedValue = portfolio.totalMarketValue
        let cashPct      = round2((portfolio.cashBalance / totalValue) * 100)
        let investedPct  = round2((investedValue / totalValue) * 100)

        let allocations: [AssetAllocation] = byType
            .map { type, value in
                AssetAllocation(
                    id:      type.rawValue,
                    label:   Self.label(for: type),
                    value:   value,
                    percent: round2((value / totalValue) * 100)
                )
            }
            .sorted { $0.value > $1.value }

        return PortfolioBreakdown(
            totalValue:      totalValue,
            cashValue:       portfolio.cashBalance,
            cashPercent:     cashPct,
            investedValue:   investedValue,
            investedPercent: investedPct,
            allocations:     allocations
        )
    }

    private static func label(for type: InstrumentType) -> String {
        switch type {
        case .stock:     return "Acciones"
        case .etf:       return "ETFs"
        case .crypto:    return "Crypto"
        case .portfolio: return "Portafolios"
        }
    }

    private func round2(_ value: Decimal) -> Decimal {
        var v = value, r = Decimal()
        NSDecimalRound(&r, &v, 2, .plain)
        return r
    }
}
