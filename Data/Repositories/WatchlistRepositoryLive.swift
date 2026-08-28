//
//  WatchlistRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

final class WatchlistRepositoryLive: WatchlistRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol
    private let cache: WatchlistCache

    init(apiClient: any APIClientProtocol, cache: WatchlistCache = WatchlistCache()) {
        self.apiClient = apiClient
        self.cache = cache
    }

    // MARK: - WatchlistRepositoryProtocol

    nonisolated func fetchWatchlist(userID: String) async throws -> [WatchlistItem] {
        if let cached = await cache.load(for: userID) { return cached }
        do {
            let dtos: [WatchlistItemDTO] = try await apiClient.request(GetWatchlistEndpoint(userID: userID))
            let items = WatchlistMapper.map(dtos)
            await cache.save(items, for: userID)
            return items
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func addToWatchlist(userID: String, instrumentID: String) async throws {
        do {
            // Codificar el body aquí (nonisolated) en lugar de dentro del init del endpoint,
            // ya que un init throwing en un struct se infiere @MainActor con default-isolation.
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(WatchlistRequestDTO(instrumentId: instrumentID))
            try await apiClient.requestVoid(
                AddToWatchlistEndpoint(userID: userID, bodyData: bodyData)
            )
            await cache.invalidate(for: userID)
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func removeFromWatchlist(userID: String, instrumentID: String) async throws {
        do {
            try await apiClient.requestVoid(
                RemoveFromWatchlistEndpoint(userID: userID, instrumentID: instrumentID)
            )
            await cache.invalidate(for: userID)
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func isInWatchlist(userID: String, instrumentID: String) async throws -> Bool {
        do {
            // 200 → en watchlist; el body es el ítem pero solo nos importa el status code.
            let _: WatchlistItemDTO = try await apiClient.request(
                CheckWatchlistEndpoint(userID: userID, instrumentID: instrumentID)
            )
            return true
        } catch {
            let mapped = mapToIFError(error)
            if case .notFound = mapped { return false }
            throw mapped
        }
    }
}
