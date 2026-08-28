//
//  WatchlistItem.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Entrada de usuario en la watchlist: qué instrumento observa y cuándo lo agregó.
/// Inmutable por diseño — los precios se obtienen vía WatchlistEntry.
public struct WatchlistItem: Identifiable, Hashable, Sendable {

    public let instrumentID: String
    public let addedAt: Date

    public var id: String { instrumentID }

    public init(instrumentID: String, addedAt: Date = Date()) {
        self.instrumentID = instrumentID
        self.addedAt = addedAt
    }
}
