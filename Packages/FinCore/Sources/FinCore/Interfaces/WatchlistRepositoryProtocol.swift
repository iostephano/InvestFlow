//
//  WatchlistRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public protocol WatchlistRepositoryProtocol: Sendable {

    /// Devuelve los ítems en la watchlist del usuario, ordenados por fecha de añadido (más reciente primero).
    func fetchWatchlist(userID: String) async throws -> [WatchlistItem]

    /// Agrega un instrumento a la watchlist. Idempotente: si ya existe, no lanza error.
    func addToWatchlist(userID: String, instrumentID: String) async throws

    /// Elimina un instrumento de la watchlist. Si no existe, no lanza error.
    func removeFromWatchlist(userID: String, instrumentID: String) async throws

    func isInWatchlist(userID: String, instrumentID: String) async throws -> Bool
}
