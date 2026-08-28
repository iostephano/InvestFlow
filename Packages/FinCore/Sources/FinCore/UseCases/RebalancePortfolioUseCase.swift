//
//  RebalancePortfolioUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public struct RebalanceSuggestion: Sendable {
    public let instrumentID: String
    public let currentWeight: Decimal
    public let targetWeight: Decimal
    public let drift: Decimal
    public let suggestedAction: OrderSide?
}

/// Calcula qué posiciones están fuera de balance respecto a pesos objetivo.
/// Threshold de rebalanceo: ±5% de desvío.
public struct RebalancePortfolioUseCase: Sendable {

    private let portfolioRepository: any PortfolioRepositoryProtocol
    private let driftThreshold: Decimal

    public init(
        portfolioRepository: any PortfolioRepositoryProtocol,
        driftThreshold: Decimal = 0.05
    ) {
        self.portfolioRepository = portfolioRepository
        self.driftThreshold = driftThreshold
    }

    public func execute(
        userID: String,
        targetWeights: [String: Decimal]
    ) async throws -> [RebalanceSuggestion] {
        let positions = try await portfolioRepository.fetchPositions(for: userID)
        let totalValue = positions.reduce(Decimal.zero) { $0 + $1.marketValue }

        guard totalValue > .zero else { return [] }

        return positions.map { position in
            let currentWeight = position.marketValue / totalValue
            let targetWeight = targetWeights[position.instrumentID] ?? .zero

            var rawDrift = currentWeight - targetWeight
            var drift = Decimal()
            NSDecimalRound(&drift, &rawDrift, 4, .plain)

            let action: OrderSide?
            if drift > driftThreshold {
                action = .sell
            } else if drift < -driftThreshold {
                action = .buy
            } else {
                action = nil
            }

            return RebalanceSuggestion(
                instrumentID:    position.instrumentID,
                currentWeight:   currentWeight,
                targetWeight:    targetWeight,
                drift:           drift,
                suggestedAction: action
            )
        }
    }
}
