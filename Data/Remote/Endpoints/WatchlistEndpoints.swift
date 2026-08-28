//
//  WatchlistEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

// MARK: - GET /users/{userID}/watchlist

struct GetWatchlistEndpoint: Endpoint {
    let userID: String
    var path:   String     { "/users/\(userID)/watchlist" }
    var method: HTTPMethod { .get }
}

// MARK: - POST /users/{userID}/watchlist

/// bodyData debe pasarse pre-codificado para evitar un init throwing en el struct,
/// que con -default-isolation MainActor se inferiría como @MainActor y no sería
/// invocable desde contextos nonisolated de los repositorios Live.
struct AddToWatchlistEndpoint: Endpoint {
    let userID: String
    var path:   String     { "/users/\(userID)/watchlist" }
    var method: HTTPMethod { .post }
    let bodyData: Data?
}

// MARK: - DELETE /users/{userID}/watchlist/{instrumentID}

struct RemoveFromWatchlistEndpoint: Endpoint {
    let userID:       String
    let instrumentID: String
    var path:   String     { "/users/\(userID)/watchlist/\(instrumentID)" }
    var method: HTTPMethod { .delete }
}

// MARK: - GET /users/{userID}/watchlist/{instrumentID}

/// Devuelve 200 con el ítem si existe, 404 si no está en la watchlist.
struct CheckWatchlistEndpoint: Endpoint {
    let userID:       String
    let instrumentID: String
    var path:   String     { "/users/\(userID)/watchlist/\(instrumentID)" }
    var method: HTTPMethod { .get }
}
