//
//  WatchlistViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class WatchlistViewModel {

    private(set) var state: LoadState<[WatchlistEntry]> = .idle

    var isEmpty: Bool {
        guard case .loaded(let entries) = state else { return false }
        return entries.isEmpty
    }

    private let userID: String
    private let getWatchlistUseCase: GetWatchlistUseCase
    private let removeFromWatchlistUseCase: RemoveFromWatchlistUseCase

    init(
        userID: String,
        getWatchlistUseCase: GetWatchlistUseCase,
        removeFromWatchlistUseCase: RemoveFromWatchlistUseCase
    ) {
        self.userID = userID
        self.getWatchlistUseCase = getWatchlistUseCase
        self.removeFromWatchlistUseCase = removeFromWatchlistUseCase
    }

    // MARK: - Acciones

    func load() async {
        state = .loading
        do {
            let entries = try await getWatchlistUseCase.execute(userID: userID)
            state = .loaded(entries)
        } catch {
            state = .failed(IFError.from(error))
        }
    }

    func retry() async {
        await load()
    }

    func remove(entry: WatchlistEntry) async {
        guard case .loaded(var entries) = state else { return }
        entries.removeAll { $0.id == entry.id }
        state = .loaded(entries)
        do {
            try await removeFromWatchlistUseCase.execute(
                userID: userID,
                instrumentID: entry.item.instrumentID
            )
        } catch {
            await load()
        }
    }
}
