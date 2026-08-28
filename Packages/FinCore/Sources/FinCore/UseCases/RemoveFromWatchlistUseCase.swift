//
//  RemoveFromWatchlistUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Elimina un instrumento de la watchlist del usuario.
public struct RemoveFromWatchlistUseCase: Sendable {

    private let repository: any WatchlistRepositoryProtocol

    public init(repository: any WatchlistRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userID: String, instrumentID: String) async throws {
        try await repository.removeFromWatchlist(userID: userID, instrumentID: instrumentID)
    }
}
