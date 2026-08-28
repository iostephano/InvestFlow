//
//  PortfolioViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class PortfolioViewModel {

    enum Tab { case overview, assets }

    private(set) var state: LoadState<Portfolio> = .idle
    private(set) var plSummary: PLSummary?
    private(set) var transactions: [Transaction] = []
    private(set) var breakdown: PortfolioBreakdown?
    private(set) var insights: PortfolioInsights?
    private(set) var rebalanceSuggestions: [RebalanceSuggestion] = []

    var selectedTab: Tab = .overview

    private let userID: String
    private let getPortfolioUseCase: GetPortfolioUseCase
    private let getTransactionHistoryUseCase: GetTransactionHistoryUseCase
    private let calculatePLUseCase: CalculatePLUseCase
    private let getBreakdownUseCase: GetPortfolioBreakdownUseCase
    private let getInsightsUseCase: GetPortfolioInsightsUseCase
    private let rebalanceUseCase: RebalancePortfolioUseCase

    init(
        userID: String,
        getPortfolioUseCase: GetPortfolioUseCase,
        getTransactionHistoryUseCase: GetTransactionHistoryUseCase,
        rebalanceUseCase: RebalancePortfolioUseCase,
        calculatePLUseCase: CalculatePLUseCase,
        getBreakdownUseCase: GetPortfolioBreakdownUseCase,
        getInsightsUseCase: GetPortfolioInsightsUseCase
    ) {
        self.userID = userID
        self.getPortfolioUseCase = getPortfolioUseCase
        self.getTransactionHistoryUseCase = getTransactionHistoryUseCase
        self.rebalanceUseCase = rebalanceUseCase
        self.calculatePLUseCase = calculatePLUseCase
        self.getBreakdownUseCase = getBreakdownUseCase
        self.getInsightsUseCase = getInsightsUseCase
    }

    var portfolio: Portfolio? {
        guard case .loaded(let p) = state else { return nil }
        return p
    }

    // MARK: - Acciones

    func load() async {
        state = .loading
        do {
            async let fetchedPortfolio    = getPortfolioUseCase.execute(userID: userID)
            async let fetchedTransactions = getTransactionHistoryUseCase.execute(userID: userID, limit: 20)

            let portfolio = try await fetchedPortfolio
            transactions  = try await fetchedTransactions

            plSummary = calculatePLUseCase.execute(portfolio: portfolio)
            let bd    = getBreakdownUseCase.execute(portfolio: portfolio)
            breakdown = bd
            insights  = getInsightsUseCase.execute(portfolio: portfolio, breakdown: bd)

            await loadRebalanceSuggestions(for: portfolio)

            state = .loaded(portfolio)
        } catch {
            IFLogger.error(error, context: "PortfolioViewModel.load")
            state = .failed(IFError.from(error))
        }
    }

    func retry() async { await load() }

    func reload() async {
        await getPortfolioUseCase.invalidateCache(for: userID)
        state = .idle
        await load()
    }

    // MARK: - Privado

    private func loadRebalanceSuggestions(for portfolio: Portfolio) async {
        let count = portfolio.positions.count
        guard count > 0 else { return }
        let equalWeight = Decimal(1) / Decimal(count)
        let targets = Dictionary(
            uniqueKeysWithValues: portfolio.positions.map { ($0.instrumentID, equalWeight) }
        )
        let all = try? await rebalanceUseCase.execute(userID: userID, targetWeights: targets)
        rebalanceSuggestions = all?.filter { $0.suggestedAction != nil } ?? []
    }
}
