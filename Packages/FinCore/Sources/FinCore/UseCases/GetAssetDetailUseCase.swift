//
//  GetAssetDetailUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public struct GetAssetDetailUseCase: Sendable {

    private let repository: any MarketRepositoryProtocol

    public init(repository: any MarketRepositoryProtocol) {
        self.repository = repository
    }

    /// Obtiene un instrumento y su cotización actual en paralelo.
    /// Lanza `IFError.notFound` cuando el símbolo no existe en el catálogo.
    public func execute(symbol: String) async throws -> (Instrument, Quote) {
        async let instrument = repository.fetchInstrument(symbol: symbol)
        async let quote = repository.fetchQuote(for: symbol)

        guard let found = try await instrument else {
            throw IFError.notFound("el instrumento \(symbol)")
        }
        return (found, try await quote)
    }
}
