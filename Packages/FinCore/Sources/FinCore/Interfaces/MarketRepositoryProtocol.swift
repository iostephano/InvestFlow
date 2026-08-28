//
//  MarketRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public protocol MarketRepositoryProtocol: Sendable {
    func fetchInstruments() async throws -> [Instrument]

    /// Devuelve un instrumento por símbolo, o nil si no existe en el catálogo.
    func fetchInstrument(symbol: String) async throws -> Instrument?

    func fetchQuote(for instrumentID: String) async throws -> Quote

    /// Devuelve múltiples cotizaciones en paralelo.
    func fetchQuotes(for instrumentIDs: [String]) async throws -> [Quote]
}
