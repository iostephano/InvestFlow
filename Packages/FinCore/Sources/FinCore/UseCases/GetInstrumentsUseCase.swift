//
//  GetInstrumentsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public struct GetInstrumentsUseCase: Sendable {

    private let repository: any MarketRepositoryProtocol

    public init(repository: any MarketRepositoryProtocol) {
        self.repository = repository
    }

    /// Devuelve los instrumentos activos emparejados con su cotización actual.
    public func execute() async throws -> [(Instrument, Quote)] {
        let instruments = try await repository.fetchInstruments()
        let active = instruments.filter(\.isActive)

        let ids = active.map(\.id)
        let quotes = try await repository.fetchQuotes(for: ids)

        let quoteMap = Dictionary(uniqueKeysWithValues: quotes.map { ($0.id, $0) })
        
        return active.compactMap { instrument in
            guard let quote = quoteMap[instrument.id] else { return nil }
            return (instrument, quote)
        }
    }
}
