//
//  RefreshMarketDataUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Refresca cotizaciones de mercado bajo demanda.
/// Usado por AssetDetailViewModel para polling de precios.
public struct RefreshMarketDataUseCase: Sendable {

    private let repository: any MarketRepositoryProtocol

    public init(repository: any MarketRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(instrumentID: String) async throws -> Quote {
        try await repository.fetchQuote(for: instrumentID)
    }

    public func execute(instrumentIDs: [String]) async throws -> [Quote] {
        try await repository.fetchQuotes(for: instrumentIDs)
    }
}
