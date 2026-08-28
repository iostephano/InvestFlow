//
//  HomeViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    func makeViewModel(
        userProfile: UserProfile = .stub(),
        error: Error? = nil,
        watchlistItems: [WatchlistItem] = [],
        watchlistError: Error? = nil
    ) -> HomeViewModel {
        HomeViewModel(
            userID: "u1",
            getUserProfileUseCase: GetUserProfileUseCase(
                repository: MockPortfolioRepository(
                    userProfile: userProfile,
                    error: error
                )
            ),
            getWatchlistUseCase: GetWatchlistUseCase(
                watchlistRepository: MockWatchlistRepository(
                    watchlistItems: watchlistItems,
                    fetchError: watchlistError
                ),
                marketRepository: MockMarketRepository()
            )
        )
    }

    // MARK: - Estado inicial

    @Test func initialState_isIdle() {
        let vm = makeViewModel()
        guard case .idle = vm.loadState else {
            Issue.record("Expected .idle, got \(vm.loadState)")
            return
        }
    }

    // MARK: - Carga exitosa

    @Test func load_success_populatesUserName() async throws {
        let profile = UserProfile.stub()
        let vm = makeViewModel(userProfile: profile)

        await vm.load()

        #expect(vm.userName == profile.firstName)
    }

    @Test func load_success_populatesBuyingPower() async throws {
        let vm = makeViewModel(userProfile: .stub(cashBalance: 12_345))

        await vm.load()

        #expect(vm.buyingPower == 12_345)
    }

    @Test func load_success_stateIsLoaded() async throws {
        let vm = makeViewModel()

        await vm.load()

        guard case .loaded = vm.loadState else {
            Issue.record("Expected .loaded, got \(vm.loadState)")
            return
        }
    }

    // MARK: - Carga fallida

    @Test func load_failure_stateIsFailed() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()

        guard case .failed = vm.loadState else {
            Issue.record("Expected .failed, got \(vm.loadState)")
            return
        }
    }

    @Test func load_failure_doesNotPopulateUserName() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()

        #expect(vm.userName.isEmpty)
    }

    // MARK: - Reintento

    @Test func retry_fromFailedState_remainsFailedWithSameRepo() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()
        guard case .failed = vm.loadState else {
            Issue.record("Pre-condition: expected .failed")
            return
        }

        await vm.retry()

        guard case .failed = vm.loadState else {
            Issue.record("Expected .failed after retry with same failing repo")
            return
        }
    }

    @Test func retry_fromSuccessfulState_reloadsWithSameData() async throws {
        let vm = makeViewModel(userProfile: .stub(cashBalance: 999))

        await vm.load()
        #expect(vm.buyingPower == 999)

        await vm.retry()

        #expect(vm.buyingPower == 999)
        guard case .loaded = vm.loadState else {
            Issue.record("Expected .loaded after retry on successful repo")
            return
        }
    }

    // MARK: - Snapshot de watchlist

    @Test func load_watchlistEmpty_snapshotIsEmpty() async throws {
        let vm = makeViewModel(watchlistItems: [])

        await vm.load()

        #expect(vm.watchlistSnapshot.isEmpty)
    }

    @Test func load_watchlistFailure_homeStillLoads() async throws {
        let vm = makeViewModel(watchlistError: MockError.simulatedFailure)

        await vm.load()

        // El perfil debe tener éxito a pesar del error de watchlist
        guard case .loaded = vm.loadState else {
            Issue.record("Expected .loaded even when watchlist fails")
            return
        }
        #expect(vm.watchlistSnapshot.isEmpty)
    }

    @Test func load_watchlistCappedAt3() async throws {
        let items: [WatchlistItem] = ["A", "B", "C", "D", "E"].map {
            WatchlistItem(instrumentID: $0)
        }
        let vm = makeViewModel(watchlistItems: items)

        await vm.load()

        #expect(vm.watchlistSnapshot.count <= 3)
    }
}
