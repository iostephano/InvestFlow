//
//  MockMarketRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

struct MockMarketRepository: MarketRepositoryProtocol {

    let instruments: [Instrument]
    let quotes: [Quote]
    let error: Error?

    init(
        instruments: [Instrument] = [],
        quotes: [Quote] = [],
        error: Error? = nil
    ) {
        self.instruments = instruments
        self.quotes = quotes
        self.error = error
    }

    func fetchInstruments() async throws -> [Instrument] {
        if let error { throw error }
        return instruments
    }

    func fetchInstrument(symbol: String) async throws -> Instrument? {
        if let error { throw error }
        return instruments.first(where: { $0.id == symbol })
    }

    func fetchQuote(for instrumentID: String) async throws -> Quote {
        if let error { throw error }
        guard let quote = quotes.first(where: { $0.id == instrumentID }) else {
            throw MockError.notFound
        }
        return quote
    }

    func fetchQuotes(for instrumentIDs: [String]) async throws -> [Quote] {
        if let error { throw error }
        return quotes.filter { instrumentIDs.contains($0.id) }
    }
}
