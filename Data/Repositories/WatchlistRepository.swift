//
//  WatchlistRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

/// Repositorio de watchlist solo para dev. Simula latencia de red y persiste las mutaciones en memoria durante la sesión.
public final class WatchlistRepository: WatchlistRepositoryProtocol, Sendable {

    private let store: WatchlistStore

    public init(preloaded: Set<String> = ["AAPL", "TSLA", "BTC", "ETH"]) {
        store = WatchlistStore(preloaded: preloaded)
    }

    // MARK: - WatchlistRepositoryProtocol

    public func fetchWatchlist(userID: String) async throws -> [WatchlistItem] {
        try await Task.sleep(for: .milliseconds(100))
        return await store.allItems()
    }

    public func addToWatchlist(userID: String, instrumentID: String) async throws {
        try await Task.sleep(for: .milliseconds(60))
        await store.add(instrumentID)
    }

    public func removeFromWatchlist(userID: String, instrumentID: String) async throws {
        try await Task.sleep(for: .milliseconds(60))
        await store.remove(instrumentID)
    }

    public func isInWatchlist(userID: String, instrumentID: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(40))
        return await store.contains(instrumentID)
    }
}

// MARK: - Store mutable interno

private actor WatchlistStore {

    private var instrumentIDs: Set<String>

    init(preloaded: Set<String>) {
        instrumentIDs = preloaded
    }

    func add(_ instrumentID: String) {
        instrumentIDs.insert(instrumentID)
    }

    func remove(_ instrumentID: String) {
        instrumentIDs.remove(instrumentID)
    }

    func contains(_ instrumentID: String) -> Bool {
        instrumentIDs.contains(instrumentID)
    }

    func allItems() -> [WatchlistItem] {
        // Orden determinista: más reciente primero, intervalos de 1 día entre ítems.
        instrumentIDs.sorted().enumerated().map { index, id in
            WatchlistItem(
                instrumentID: id,
                addedAt: Date().addingTimeInterval(Double(-index) * 86_400)
            )
        }
    }
}
