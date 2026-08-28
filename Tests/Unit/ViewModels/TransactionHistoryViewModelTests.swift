//
//  TransactionHistoryViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("TransactionHistoryViewModel")
@MainActor
struct TransactionHistoryViewModelTests {

    private let buyTx   = Transaction.stub(id: "t1", type: .buy)
    private let sellTx  = Transaction.stub(id: "t2", type: .sell)
    private let depTx   = Transaction.stub(id: "t3", type: .deposit)

    func makeViewModel(
        transactions: [Transaction] = [],
        error: Error? = nil
    ) -> TransactionHistoryViewModel {
        TransactionHistoryViewModel(
            userID: "u1",
            getTransactionHistoryUseCase: GetTransactionHistoryUseCase(
                repository: MockPortfolioRepository(
                    transactions: transactions,
                    error: error
                )
            )
        )
    }

    // MARK: - Carga

    @Test func load_success_stateIsLoaded() async throws {
        let vm = makeViewModel(transactions: [buyTx])
        await vm.load()
        guard case .loaded = vm.loadState else {
            Issue.record("Expected .loaded, got \(vm.loadState)")
            return
        }
    }

    @Test func load_failure_stateIsFailed() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)
        await vm.load()
        guard case .failed = vm.loadState else {
            Issue.record("Expected .failed, got \(vm.loadState)")
            return
        }
    }

    @Test func load_emptyTransactions_isEmpty() async throws {
        let vm = makeViewModel(transactions: [])
        await vm.load()
        #expect(vm.isEmpty)
    }

    // MARK: - Filtros

    @Test func filter_all_returnsAllTransactions() async throws {
        let vm = makeViewModel(transactions: [buyTx, sellTx, depTx])
        await vm.load()
        vm.selectedFilter = .all
        #expect(vm.filteredTransactions.count == 3)
    }

    @Test func filter_buy_returnsOnlyBuyTransactions() async throws {
        let vm = makeViewModel(transactions: [buyTx, sellTx, depTx])
        await vm.load()
        vm.selectedFilter = .buy
        #expect(vm.filteredTransactions.count == 1)
        #expect(vm.filteredTransactions.first?.type == .buy)
    }

    @Test func filter_sell_returnsOnlySellTransactions() async throws {
        let vm = makeViewModel(transactions: [buyTx, sellTx, depTx])
        await vm.load()
        vm.selectedFilter = .sell
        #expect(vm.filteredTransactions.count == 1)
        #expect(vm.filteredTransactions.first?.type == .sell)
    }

    @Test func filter_deposit_returnsOnlyDeposits() async throws {
        let vm = makeViewModel(transactions: [buyTx, sellTx, depTx])
        await vm.load()
        vm.selectedFilter = .deposit
        #expect(vm.filteredTransactions.count == 1)
        #expect(vm.filteredTransactions.first?.type == .deposit)
    }

    @Test func filter_withdrawal_returnsEmpty_whenNoWithdrawals() async throws {
        let vm = makeViewModel(transactions: [buyTx, sellTx])
        await vm.load()
        vm.selectedFilter = .withdrawal
        #expect(vm.filteredTransactions.isEmpty)
    }

    // MARK: - isEmpty

    @Test func isEmpty_afterFilteringToEmpty_isTrue() async throws {
        let vm = makeViewModel(transactions: [buyTx])
        await vm.load()
        vm.selectedFilter = .deposit
        #expect(vm.isEmpty)
    }

    @Test func isEmpty_withMatchingFilter_isFalse() async throws {
        let vm = makeViewModel(transactions: [buyTx])
        await vm.load()
        vm.selectedFilter = .buy
        #expect(!vm.isEmpty)
    }
}
