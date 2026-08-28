//
//  AssetDetailViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("AssetDetailViewModel")
@MainActor
struct AssetDetailViewModelTests {

    func makeViewModel(
        instrumentID: String = "AAPL",
        instruments: [Instrument] = [.stub(id: "AAPL")],
        quotes: [Quote] = [.stub(id: "AAPL", price: 150)],
        error: Error? = nil
    ) -> AssetDetailViewModel {
        let repo = MockMarketRepository(instruments: instruments, quotes: quotes, error: error)
        let watchlistRepo = MockWatchlistRepository()
        return AssetDetailViewModel(
            instrumentID: instrumentID,
            userID: "u1",
            getAssetDetailUseCase: GetAssetDetailUseCase(repository: repo),
            refreshMarketDataUseCase: RefreshMarketDataUseCase(repository: repo),
            addToWatchlistUseCase: AddToWatchlistUseCase(repository: watchlistRepo),
            removeFromWatchlistUseCase: RemoveFromWatchlistUseCase(repository: watchlistRepo),
            checkWatchlistStatusUseCase: CheckWatchlistStatusUseCase(repository: watchlistRepo)
        )
    }

    // MARK: - Carga exitosa

    @Test func load_success_instrumentIsAvailable() async throws {
        let vm = makeViewModel()

        await vm.load()

        #expect(vm.instrument?.id == "AAPL")
    }

    @Test func load_success_quoteIsAvailable() async throws {
        let vm = makeViewModel(quotes: [.stub(id: "AAPL", price: 200)])

        await vm.load()

        #expect(vm.quote?.price == 200)
    }

    @Test func load_success_stateIsLoaded() async throws {
        let vm = makeViewModel()

        await vm.load()

        guard case .loaded = vm.state else {
            Issue.record("Expected .loaded, got \(vm.state)")
            return
        }
    }

    // MARK: - No encontrado

    @Test func load_instrumentNotFound_stateIsFailed() async throws {
        // Sin instrumentos en el repo → fetchInstrument devuelve nil → IFError.notFound
        let vm = makeViewModel(instruments: [], quotes: [.stub(id: "AAPL")])

        await vm.load()

        guard case .failed = vm.state else {
            Issue.record("Expected .failed for missing instrument, got \(vm.state)")
            return
        }
    }

    @Test func load_instrumentNotFound_instrumentIsNil() async throws {
        let vm = makeViewModel(instruments: [])

        await vm.load()

        #expect(vm.instrument == nil)
    }

    // MARK: - Error de red

    @Test func load_networkError_stateIsFailed() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)

        await vm.load()

        guard case .failed = vm.state else {
            Issue.record("Expected .failed for network error, got \(vm.state)")
            return
        }
    }

    // MARK: - refreshQuote

    @Test func refreshQuote_updatesQuoteWithoutChangingInstrument() async throws {
        let firstRepo = MockMarketRepository(
            instruments: [.stub(id: "AAPL")],
            quotes: [.stub(id: "AAPL", price: 150)]
        )
        let watchlistRepo = MockWatchlistRepository()
        let vm = AssetDetailViewModel(
            instrumentID: "AAPL",
            userID: "u1",
            getAssetDetailUseCase: GetAssetDetailUseCase(repository: firstRepo),
            refreshMarketDataUseCase: RefreshMarketDataUseCase(
                repository: MockMarketRepository(
                    instruments: [.stub(id: "AAPL")],
                    quotes: [.stub(id: "AAPL", price: 999)]
                )
            ),
            addToWatchlistUseCase: AddToWatchlistUseCase(repository: watchlistRepo),
            removeFromWatchlistUseCase: RemoveFromWatchlistUseCase(repository: watchlistRepo),
            checkWatchlistStatusUseCase: CheckWatchlistStatusUseCase(repository: watchlistRepo)
        )

        await vm.load()
        let originalInstrumentID = vm.instrument?.id

        await vm.refreshQuote()

        #expect(vm.quote?.price == 999)
        #expect(vm.instrument?.id == originalInstrumentID)
    }

    @Test func refreshQuote_whenNotLoaded_doesNothing() async throws {
        let vm = makeViewModel()
        // El estado es .idle, refreshQuote debe ser un no-op

        await vm.refreshQuote()

        guard case .idle = vm.state else {
            Issue.record("Expected state to remain .idle, got \(vm.state)")
            return
        }
    }

    @Test func refreshQuote_onError_preservesExistingQuote() async throws {
        let initialRepo = MockMarketRepository(
            instruments: [.stub(id: "AAPL")],
            quotes: [.stub(id: "AAPL", price: 150)]
        )
        let failingRefreshRepo = MockMarketRepository(error: MockError.simulatedFailure)
        let watchlistRepo = MockWatchlistRepository()
        let vm = AssetDetailViewModel(
            instrumentID: "AAPL",
            userID: "u1",
            getAssetDetailUseCase: GetAssetDetailUseCase(repository: initialRepo),
            refreshMarketDataUseCase: RefreshMarketDataUseCase(repository: failingRefreshRepo),
            addToWatchlistUseCase: AddToWatchlistUseCase(repository: watchlistRepo),
            removeFromWatchlistUseCase: RemoveFromWatchlistUseCase(repository: watchlistRepo),
            checkWatchlistStatusUseCase: CheckWatchlistStatusUseCase(repository: watchlistRepo)
        )

        await vm.load()
        await vm.refreshQuote()

        // El error de refresco no es fatal — la cotización original debe permanecer
        #expect(vm.quote?.price == 150)
    }
}
