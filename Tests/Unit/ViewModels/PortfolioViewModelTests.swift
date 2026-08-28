//
//  PortfolioViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("PortfolioViewModel")
@MainActor
struct PortfolioViewModelTests {

    func makeViewModel(
        portfolio: Portfolio = .stub(positions: [.stub()]),
        transactions: [Transaction] = [.stub()],
        error: Error? = nil
    ) -> PortfolioViewModel {
        let repo = MockPortfolioRepository(
            portfolio: portfolio,
            transactions: transactions,
            error: error
        )
        return PortfolioViewModel(
            userID: "u1",
            getPortfolioUseCase: GetPortfolioUseCase(repository: repo),
            getTransactionHistoryUseCase: GetTransactionHistoryUseCase(repository: repo),
            rebalanceUseCase: RebalancePortfolioUseCase(portfolioRepository: repo),
            calculatePLUseCase: CalculatePLUseCase(),
            getBreakdownUseCase: GetPortfolioBreakdownUseCase(),
            getInsightsUseCase: GetPortfolioInsightsUseCase()
        )
    }

    // MARK: - Estado inicial

    @Test func initialState_isIdle() {
        let vm = makeViewModel()
        guard case .idle = vm.state else {
            Issue.record("Expected .idle, got \(vm.state)")
            return
        }
    }

    // MARK: - Carga exitosa

    @Test func load_success_portfolioIsAvailable() async throws {
        let portfolio = Portfolio.stub(positions: [.stub()])
        let vm = makeViewModel(portfolio: portfolio)

        await vm.load()

        #expect(vm.portfolio?.userID == portfolio.userID)
    }

    @Test func load_success_transactionsAreLoaded() async throws {
        let tx = [Transaction.stub(), Transaction.stub(id: "tx-2")]
        let vm = makeViewModel(transactions: tx)

        await vm.load()

        #expect(vm.transactions.count == 2)
    }

    @Test func load_success_stateIsLoaded() async throws {
        let vm = makeViewModel()

        await vm.load()

        guard case .loaded = vm.state else {
            Issue.record("Expected .loaded, got \(vm.state)")
            return
        }
    }

    @Test func load_success_plSummaryIsNotNil() async throws {
        let vm = makeViewModel(portfolio: .stub(positions: [.stub()]))

        await vm.load()

        #expect(vm.plSummary != nil)
    }

    @Test func load_success_breakdownHasAllocations() async throws {
        let position = Position.stub(instrumentType: .stock, quantity: 10, currentPrice: 150)
        let portfolio = Portfolio.stub(positions: [position], cashBalance: 500)
        let vm = makeViewModel(portfolio: portfolio)

        await vm.load()

        #expect((vm.breakdown?.allocations.isEmpty) == false)
    }

    // MARK: - Carga concurrente

    @Test func load_portfolioAndTransactionsLoadConcurrently() async throws {
        let portfolio = Portfolio.stub(positions: [.stub()])
        let transactions = [Transaction.stub()]
        let vm = makeViewModel(portfolio: portfolio, transactions: transactions)

        await vm.load()

        // Ambos deben quedar poblados tras un solo load()
        #expect(vm.portfolio != nil)
        #expect(!vm.transactions.isEmpty)
    }

    // MARK: - Fallo

    @Test func load_failure_stateIsFailed() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()

        guard case .failed = vm.state else {
            Issue.record("Expected .failed, got \(vm.state)")
            return
        }
    }

    @Test func load_failure_plSummaryRemainsNil() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()

        #expect(vm.plSummary == nil)
    }
}
