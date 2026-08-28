//
//  RebalancePortfolioUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("RebalancePortfolioUseCase")
struct RebalancePortfolioUseCaseTests {

    // Dos posiciones que reparten 70/30 sobre totalValue=1000
    // pos A: qty=7, price=100 → marketValue=700 → weight=0.70
    // pos B: qty=3, price=100 → marketValue=300 → weight=0.30
    let posA = Position.stub(instrumentID: "A", quantity: 7, averageCostBasis: 50, currentPrice: 100)
    let posB = Position.stub(instrumentID: "B", quantity: 3, averageCostBasis: 50, currentPrice: 100)

    func makeUseCase(positions: [Position]) -> RebalancePortfolioUseCase {
        RebalancePortfolioUseCase(
            portfolioRepository: MockPortfolioRepository(positions: positions)
        )
    }

    // MARK: - Señal de venta

    @Test func givenPositiveDriftAboveThreshold_whenExecuted_thenSuggestsSell() async throws {
        let useCase = makeUseCase(positions: [posA, posB])
        // A weight actual=0.70, target=0.60 → drift=0.10 > 0.05 → vender
        let suggestions = try await useCase.execute(userID: "u1", targetWeights: ["A": "0.60", "B": "0.40"].decimalValues)

        let suggestionA = try #require(suggestions.first { $0.instrumentID == "A" })
        #expect(suggestionA.suggestedAction == .sell)
    }

    // MARK: - Señal de compra

    @Test func givenNegativeDriftBelowThreshold_whenExecuted_thenSuggestsBuy() async throws {
        let useCase = makeUseCase(positions: [posA, posB])
        // B weight actual=0.30, target=0.40 → drift=-0.10 < -0.05 → comprar
        let suggestions = try await useCase.execute(userID: "u1", targetWeights: ["A": "0.60", "B": "0.40"].decimalValues)

        let suggestionB = try #require(suggestions.first { $0.instrumentID == "B" })
        #expect(suggestionB.suggestedAction == .buy)
    }

    // MARK: - Sin acción

    @Test func givenDriftWithinThreshold_whenExecuted_thenNoAction() async throws {
        let useCase = makeUseCase(positions: [posA, posB])
        // A: weight=0.70, target=0.68 → drift=0.02 < 0.05 → nil
        // B: weight=0.30, target=0.32 → drift=-0.02 > -0.05 → nil
        let suggestions = try await useCase.execute(
            userID: "u1",
            targetWeights: ["A": "0.68", "B": "0.32"].decimalValues
        )

        #expect(suggestions.allSatisfy { $0.suggestedAction == nil })
    }

    // MARK: - Portafolio vacío

    @Test func givenNoPositions_whenExecuted_thenReturnsEmptyArray() async throws {
        let useCase = makeUseCase(positions: [])

        let suggestions = try await useCase.execute(userID: "u1", targetWeights: ["A": "1.0"].decimalValues)

        #expect(suggestions.isEmpty)
    }

    // MARK: - Instrumento ausente en los pesos objetivo

    @Test func givenInstrumentNotInTargetWeights_whenExecuted_thenTreatedAsZeroTarget() async throws {
        let useCase = makeUseCase(positions: [posA])
        // A: weight=1.0, target=0.0 (no está en el dict) → drift=1.0 → vender
        let suggestions = try await useCase.execute(userID: "u1", targetWeights: [:])

        let suggestionA = try #require(suggestions.first { $0.instrumentID == "A" })
        #expect(suggestionA.suggestedAction == .sell)
        #expect(suggestionA.targetWeight == .zero)
    }

    // MARK: - Threshold personalizado

    @Test func givenCustomThreshold_whenDriftBelowIt_thenNoAction() async throws {
        let useCase = RebalancePortfolioUseCase(
            portfolioRepository: MockPortfolioRepository(positions: [posA, posB]),
            driftThreshold: Decimal(string: "0.15")!
        )
        // A: drift=0.10, threshold=0.15 → sin acción
        let suggestions = try await useCase.execute(
            userID: "u1",
            targetWeights: ["A": "0.60", "B": "0.40"].decimalValues
        )

        #expect(suggestions.allSatisfy { $0.suggestedAction == nil })
    }
}

// MARK: - Auxiliar

private extension Dictionary where Key == String, Value == String {
    var decimalValues: [String: Decimal] {
        compactMapValues { Decimal(string: $0) }
    }
}
