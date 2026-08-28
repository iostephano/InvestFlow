//
//  WatchlistViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("WatchlistViewModel")
@MainActor
struct WatchlistViewModelTests {

    func makeViewModel(
        watchlistItems: [WatchlistItem] = [],
        instruments: [Instrument] = [],
        quotes: [Quote] = [],
        fetchError: Error? = nil,
        removeError: Error? = nil
    ) -> WatchlistViewModel {
        let watchlistRepo = MockWatchlistRepository(
            watchlistItems: watchlistItems,
            fetchError: fetchError,
            removeError: removeError
        )
        let marketRepo = MockMarketRepository(instruments: instruments, quotes: quotes)
        return WatchlistViewModel(
            userID: "u1",
            getWatchlistUseCase: GetWatchlistUseCase(
                watchlistRepository: watchlistRepo,
                marketRepository: marketRepo
            ),
            removeFromWatchlistUseCase: RemoveFromWatchlistUseCase(repository: watchlistRepo)
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

    @Test func load_success_setsLoadedEntries() async {
        let vm = makeViewModel(
            watchlistItems: [.stub(instrumentID: "AAPL")],
            instruments: [.stub(id: "AAPL")],
            quotes: [.stub(id: "AAPL", price: 150)]
        )

        await vm.load()

        guard case .loaded(let entries) = vm.state else {
            Issue.record("Expected .loaded, got \(vm.state)")
            return
        }
        #expect(entries.count == 1)
        #expect(entries.first?.id == "AAPL")
        #expect(entries.first?.quote.price == 150)
    }

    @Test func load_success_emptyWatchlist_setsLoadedEmpty() async {
        let vm = makeViewModel()

        await vm.load()

        guard case .loaded(let entries) = vm.state else {
            Issue.record("Expected .loaded([]), got \(vm.state)")
            return
        }
        #expect(entries.isEmpty)
        #expect(vm.isEmpty)
    }

    // MARK: - Fallo de carga

    @Test func load_failure_setsFailedState() async {
        let vm = makeViewModel(fetchError: MockError.simulatedFailure)

        await vm.load()

        guard case .failed = vm.state else {
            Issue.record("Expected .failed, got \(vm.state)")
            return
        }
    }

    // MARK: - Reintento

    @Test func retry_afterFailure_callsLoadAgain() async {
        let vm = makeViewModel(fetchError: MockError.simulatedFailure)
        await vm.load()

        await vm.retry()

        // retry() delega en load() — el repo con el mismo error vuelve a producir .failed
        guard case .failed = vm.state else {
            Issue.record("Expected .failed after retry, got \(vm.state)")
            return
        }
    }

    // MARK: - Eliminar

    @Test func remove_success_removesEntryOptimistically() async {
        let vm = makeViewModel(
            watchlistItems: [.stub(instrumentID: "AAPL")],
            instruments: [.stub(id: "AAPL")],
            quotes: [.stub(id: "AAPL", price: 150)]
        )
        await vm.load()

        await vm.remove(entry: .stub(instrumentID: "AAPL"))

        guard case .loaded(let entries) = vm.state else {
            Issue.record("Expected .loaded after remove, got \(vm.state)")
            return
        }
        #expect(entries.isEmpty)
    }

    @Test func remove_failure_reloadsOriginalEntries() async {
        let vm = makeViewModel(
            watchlistItems: [.stub(instrumentID: "AAPL")],
            instruments: [.stub(id: "AAPL")],
            quotes: [.stub(id: "AAPL", price: 150)],
            removeError: MockError.simulatedFailure
        )
        await vm.load()

        await vm.remove(entry: .stub(instrumentID: "AAPL"))

        // remove falla → el VM llama a load() → se restauran los datos del servidor
        guard case .loaded(let entries) = vm.state else {
            Issue.record("Expected .loaded after failed remove, got \(vm.state)")
            return
        }
        #expect(entries.count == 1)
        #expect(entries.first?.id == "AAPL")
    }
}
