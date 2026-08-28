//
//  WatchlistCache.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

/// Cache local de watchlist con TTL de 2 minutos.
/// TTL corto porque el usuario puede agregar o eliminar ítems en cualquier momento.
/// Siguiendo el mismo patrón que PortfolioCache.
public actor WatchlistCache {

    private let cache: CacheLayer
    private let ttl: TimeInterval = 120     // 2 min — watchlist cambia con acción explícita del usuario

    public init(cache: CacheLayer = .shared) {
        self.cache = cache
    }

    // MARK: - Lectura / escritura

    public func save(_ items: [WatchlistItem], for userID: String) async {
        await cache.set(items, for: key(userID), ttl: ttl)
    }

    public func load(for userID: String) async -> [WatchlistItem]? {
        await cache.get(key(userID))
    }

    // MARK: - Invalidación

    public func invalidate(for userID: String) async {
        await cache.remove(for: key(userID))
    }

    // MARK: - Clave

    private func key(_ userID: String) -> String { "watchlist_\(userID)" }
}
