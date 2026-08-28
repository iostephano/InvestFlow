//
//  PortfolioDetailViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class PortfolioDetailViewModel {

    // MARK: - Estado

    private(set) var performance: PortfolioPerformance?
    private(set) var holdings: [PortfolioHolding] = []
    private(set) var isLoading = false

    var selectedPeriod: PerformancePeriod = .oneYear

    // MARK: - Dependencias

    let portfolio: SuggestedPortfolio
    private let getPerformanceUseCase: GetPortfolioPerformanceUseCase
    private let getHoldingsUseCase: GetPortfolioHoldingsUseCase

    init(
        portfolio: SuggestedPortfolio,
        getPerformanceUseCase: GetPortfolioPerformanceUseCase,
        getHoldingsUseCase: GetPortfolioHoldingsUseCase
    ) {
        self.portfolio            = portfolio
        self.getPerformanceUseCase = getPerformanceUseCase
        self.getHoldingsUseCase   = getHoldingsUseCase
    }

    // MARK: - Acciones

    func load() async {
        guard performance == nil else { return }
        isLoading = true
        try? await Task.sleep(for: .milliseconds(120))
        holdings    = getHoldingsUseCase.execute(portfolioID: portfolio.id)
        performance = getPerformanceUseCase.execute(portfolioID: portfolio.id, period: selectedPeriod)
        isLoading = false
    }

    func selectPeriod(_ period: PerformancePeriod) {
        selectedPeriod = period
        performance = getPerformanceUseCase.execute(portfolioID: portfolio.id, period: period)
    }
}
