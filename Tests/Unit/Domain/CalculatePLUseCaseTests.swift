//
//  CalculatePLUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("CalculatePLUseCase")
struct CalculatePLUseCaseTests {

    let useCase = CalculatePLUseCase()

    // MARK: - Ganancia

    @Test func givenProfitPosition_whenExecuted_thenSummaryIsProfit() {
        let position = Position.stub(quantity: 10, averageCostBasis: 100, currentPrice: 150)
        let portfolio = Portfolio.stub(positions: [position], cashBalance: 500)

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.isProfit)
        #expect(summary.totalMarketValue == 1500)
        #expect(summary.totalCostBasis == 1000)
        #expect(summary.totalUnrealizedPL == 500)
        #expect(summary.positionCount == 1)
    }

    // MARK: - Pérdida

    @Test func givenLossPosition_whenExecuted_thenSummaryIsNotProfit() {
        let position = Position.stub(quantity: 10, averageCostBasis: 150, currentPrice: 100)
        let portfolio = Portfolio.stub(positions: [position])

        let summary = useCase.execute(portfolio: portfolio)

        #expect(!summary.isProfit)
        #expect(summary.totalUnrealizedPL == -500)
        #expect(summary.totalMarketValue == 1000)
        #expect(summary.totalCostBasis == 1500)
    }

    // MARK: - Portafolio vacío

    @Test func givenNoPositions_whenExecuted_thenAllMetricsAreZero() {
        let portfolio = Portfolio.stub(positions: [], cashBalance: 2000)

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.positionCount == 0)
        #expect(summary.totalMarketValue == .zero)
        #expect(summary.totalCostBasis == .zero)
        #expect(summary.totalUnrealizedPL == .zero)
        #expect(summary.bestPosition == nil)
        #expect(summary.worstPosition == nil)
    }

    // MARK: - Cash

    @Test func givenCashBalance_whenExecuted_thenTotalPortfolioValueIncludesCash() {
        let position = Position.stub(quantity: 10, averageCostBasis: 100, currentPrice: 150)
        let portfolio = Portfolio.stub(positions: [position], cashBalance: 500)

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.totalPortfolioValue == 2000)
        #expect(summary.cashBalance == 500)
    }

    // MARK: - Porcentaje de P&L

    @Test func givenProfitPosition_whenExecuted_thenPLPercentIsCorrect() {
        let position = Position.stub(quantity: 10, averageCostBasis: 100, currentPrice: 110)
        let portfolio = Portfolio.stub(positions: [position])

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.totalUnrealizedPLPercent == 10)
    }

    // MARK: - Mejor / peor posición

    @Test func givenMixedPositions_whenExecuted_thenBestAndWorstAreCorrect() {
        let winner = Position.stub(instrumentID: "AAPL", quantity: 10, averageCostBasis: 100, currentPrice: 200)
        let loser  = Position.stub(instrumentID: "TSLA", quantity: 5,  averageCostBasis: 300, currentPrice: 100)
        let portfolio = Portfolio.stub(positions: [winner, loser])

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.bestPosition?.instrumentID == "AAPL")
        #expect(summary.worstPosition?.instrumentID == "TSLA")
    }

    @Test func givenAllProfitPositions_whenExecuted_thenWorstPositionIsNil() {
        let pos1 = Position.stub(instrumentID: "AAPL", quantity: 10, averageCostBasis: 100, currentPrice: 200)
        let pos2 = Position.stub(instrumentID: "TSLA", quantity: 5,  averageCostBasis: 100, currentPrice: 150)
        let portfolio = Portfolio.stub(positions: [pos1, pos2])

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.worstPosition == nil)
        #expect(summary.bestPosition?.instrumentID == "AAPL")
    }

    @Test func givenSingleLossPosition_whenExecuted_thenWorstPositionIsSet() {
        let loser = Position.stub(quantity: 10, averageCostBasis: 200, currentPrice: 100)
        let portfolio = Portfolio.stub(positions: [loser])

        let summary = useCase.execute(portfolio: portfolio)

        #expect(summary.worstPosition != nil)
        #expect(!summary.isProfit)
    }
}
