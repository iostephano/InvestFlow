//
//  GetWatchlistUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Obtiene la watchlist del usuario enriquecida con precio actual.
/// Orquesta WatchlistRepositoryProtocol (persistencia) + MarketRepositoryProtocol (precios),
/// siguiendo el mismo patrón multi-repositorio que PlaceOrderUseCase.
public struct GetWatchlistUseCase: Sendable {

    private let watchlistRepository: any WatchlistRepositoryProtocol
    private let marketRepository: any MarketRepositoryProtocol

    public init(
        watchlistRepository: any WatchlistRepositoryProtocol,
        marketRepository: any MarketRepositoryProtocol
    ) {
        self.watchlistRepository = watchlistRepository
        self.marketRepository = marketRepository
    }

    /// Devuelve los ítems de la watchlist con cotización en tiempo real.
    /// Los instrumentos sin cotización disponible se excluyen silenciosamente del resultado.
    /// El resultado se ordena por fecha de añadido, más reciente primero.
    public func execute(userID: String) async throws -> [WatchlistEntry] {
        let items = try await watchlistRepository.fetchWatchlist(userID: userID)
        guard !items.isEmpty else { return [] }

        let watchedIDs = Set(items.map(\.instrumentID))

        // Instrumentos y cotizaciones en paralelo, igual que GetInstrumentsUseCase.
        async let allInstruments = marketRepository.fetchInstruments()
        async let quotes         = marketRepository.fetchQuotes(for: Array(watchedIDs))

        let instrumentMap = try await allInstruments
            .filter { watchedIDs.contains($0.id) }
            .reduce(into: [String: Instrument]()) { $0[$1.id] = $1 }

        let quoteMap = try await quotes
            .reduce(into: [String: Quote]()) { $0[$1.id] = $1 }

        return items.compactMap { watchItem in
            guard
                let instrument = instrumentMap[watchItem.instrumentID],
                let quote      = quoteMap[watchItem.instrumentID]
            else { return nil }
            return WatchlistEntry(
                item: watchItem,
                marketItem: MarketItem(instrument: instrument, quote: quote)
            )
        }
        .sorted { $0.addedAt > $1.addedAt }
    }
}
