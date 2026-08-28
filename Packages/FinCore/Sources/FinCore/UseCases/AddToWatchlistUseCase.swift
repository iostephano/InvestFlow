//
//  AddToWatchlistUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Agrega un instrumento a la watchlist del usuario.
public struct AddToWatchlistUseCase: Sendable {

    private let repository: any WatchlistRepositoryProtocol

    public init(repository: any WatchlistRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userID: String, instrumentID: String) async throws {
        try await repository.addToWatchlist(userID: userID, instrumentID: instrumentID)
    }
}
