//
//  AssetDetailViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class AssetDetailViewModel {

    private(set) var state: LoadState<(Instrument, Quote)> = .idle
    private(set) var isRefreshing:       Bool = false
    private(set) var isInWatchlist:      Bool = false
    private(set) var isUpdatingWatchlist: Bool = false

    let instrumentID: String

    private let userID: String
    private let getAssetDetailUseCase:       GetAssetDetailUseCase
    private let refreshMarketDataUseCase:    RefreshMarketDataUseCase
    private let addToWatchlistUseCase:       AddToWatchlistUseCase
    private let removeFromWatchlistUseCase:  RemoveFromWatchlistUseCase
    private let checkWatchlistStatusUseCase: CheckWatchlistStatusUseCase

    init(
        instrumentID: String,
        userID: String,
        getAssetDetailUseCase: GetAssetDetailUseCase,
        refreshMarketDataUseCase: RefreshMarketDataUseCase,
        addToWatchlistUseCase: AddToWatchlistUseCase,
        removeFromWatchlistUseCase: RemoveFromWatchlistUseCase,
        checkWatchlistStatusUseCase: CheckWatchlistStatusUseCase
    ) {
        self.instrumentID = instrumentID
        self.userID = userID
        self.getAssetDetailUseCase = getAssetDetailUseCase
        self.refreshMarketDataUseCase = refreshMarketDataUseCase
        self.addToWatchlistUseCase = addToWatchlistUseCase
        self.removeFromWatchlistUseCase = removeFromWatchlistUseCase
        self.checkWatchlistStatusUseCase = checkWatchlistStatusUseCase
    }

    var instrument: Instrument? {
        guard case .loaded(let pair) = state else { return nil }
        return pair.0
    }

    var quote: Quote? {
        guard case .loaded(let pair) = state else { return nil }
        return pair.1
    }

    // MARK: - Acciones

    func load() async {
        state = .loading
        do {
            let pair = try await getAssetDetailUseCase.execute(symbol: instrumentID)
            state = .loaded(pair)
            await loadWatchlistStatus()
        } catch {
            state = .failed(IFError.from(error))
        }
    }

    private func loadWatchlistStatus() async {
        do {
            isInWatchlist = try await checkWatchlistStatusUseCase.execute(
                userID: userID,
                instrumentID: instrumentID
            )
        } catch {
            // No fatal — la estrella queda vacía si hay error de red
        }
    }

    func toggleWatchlist() async {
        guard !isUpdatingWatchlist else { return }
        isUpdatingWatchlist = true
        let previous = isInWatchlist
        isInWatchlist.toggle()
        defer { isUpdatingWatchlist = false }
        do {
            if previous {
                try await removeFromWatchlistUseCase.execute(
                    userID: userID,
                    instrumentID: instrumentID
                )
            } else {
                try await addToWatchlistUseCase.execute(
                    userID: userID,
                    instrumentID: instrumentID
                )
            }
        } catch {
            isInWatchlist = previous
        }
    }

    func refreshQuote() async {
        guard case .loaded(let pair) = state else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            let newQuote = try await refreshMarketDataUseCase.execute(instrumentID: instrumentID)
            state = .loaded((pair.0, newQuote))
        } catch {
            // Los fallos de refresco no son fatales — la cotización previa sigue visible
        }
    }
}
