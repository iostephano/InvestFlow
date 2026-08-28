//
//  PortfolioInsights.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public enum RiskLevel: String, Sendable, Hashable {
    case conservative = "CONSERVATIVE"
    case moderate     = "MODERATE"
    case aggressive   = "AGGRESSIVE"

    public var displayName: String {
        switch self {
        case .conservative: return "Conservador"
        case .moderate:     return "Moderado"
        case .aggressive:   return "Agresivo"
        }
    }

    public var icon: String {
        switch self {
        case .conservative: return "shield.fill"
        case .moderate:     return "chart.bar.fill"
        case .aggressive:   return "flame.fill"
        }
    }
}

public struct SuggestedPortfolio: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let expectedReturnPercent: Decimal
    public let riskLevel: RiskLevel

    public init(
        id: String,
        name: String,
        description: String,
        expectedReturnPercent: Decimal,
        riskLevel: RiskLevel
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.expectedReturnPercent = expectedReturnPercent
        self.riskLevel = riskLevel
    }
}

public struct PortfolioInsights: Sendable {
    public let diversificationScore: Int
    public let riskLevel: RiskLevel
    public let topHolding: Position?
    public let topHoldingPercent: Decimal
    public let suggestedPortfolios: [SuggestedPortfolio]

    public init(
        diversificationScore: Int,
        riskLevel: RiskLevel,
        topHolding: Position?,
        topHoldingPercent: Decimal,
        suggestedPortfolios: [SuggestedPortfolio]
    ) {
        self.diversificationScore = diversificationScore
        self.riskLevel = riskLevel
        self.topHolding = topHolding
        self.topHoldingPercent = topHoldingPercent
        self.suggestedPortfolios = suggestedPortfolios
    }
}
