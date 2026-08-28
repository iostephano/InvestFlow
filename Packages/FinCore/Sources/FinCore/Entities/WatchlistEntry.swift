//
//  WatchlistEntry.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Agrega WatchlistItem + MarketItem para las pantallas de watchlist.
/// Sigue el mismo patrón que MarketItem (Instrument + Quote):
/// el dominio separa metadatos estáticos del precio en tiempo real.
public struct WatchlistEntry: Identifiable, Sendable {

    public let item: WatchlistItem
    public let marketItem: MarketItem

    public var id: String         { item.id }
    public var instrument: Instrument { marketItem.instrument }
    public var quote: Quote           { marketItem.quote }
    public var addedAt: Date          { item.addedAt }

    public init(item: WatchlistItem, marketItem: MarketItem) {
        self.item = item
        self.marketItem = marketItem
    }
}
