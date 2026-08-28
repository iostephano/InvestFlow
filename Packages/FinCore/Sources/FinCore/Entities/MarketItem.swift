//
//  MarketItem.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Agrega Instrument + Quote para mostrarlos en las pantallas de mercado.
public struct MarketItem: Identifiable, Sendable {
    public let instrument: Instrument
    public let quote: Quote

    public var id: String { instrument.id }

    public init(instrument: Instrument, quote: Quote) {
        self.instrument = instrument
        self.quote = quote
    }
}
