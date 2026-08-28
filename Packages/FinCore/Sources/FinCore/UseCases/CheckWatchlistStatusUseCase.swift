//
//  CheckWatchlistStatusUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Consulta si un instrumento concreto está en la watchlist del usuario.
/// Útil para que AssetDetail y MarketItem muestren el estado del icono de watchlist.
public struct CheckWatchlistStatusUseCase: Sendable {

    private let repository: any WatchlistRepositoryProtocol

    public init(repository: any WatchlistRepositoryProtocol) {
        self.repository = repository
    }

    /// Devuelve `true` si el instrumento está en la watchlist del usuario.
    public func execute(userID: String, instrumentID: String) async throws -> Bool {
        try await repository.isInWatchlist(userID: userID, instrumentID: instrumentID)
    }
}
