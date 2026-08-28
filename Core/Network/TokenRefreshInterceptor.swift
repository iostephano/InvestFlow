//
//  TokenRefreshInterceptor.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Gestiona el ciclo de vida de tokens de acceso de InvestFlow.
/// Actor garantiza que solo un refresh ocurra a la vez incluso con requests concurrentes.
public actor TokenRefreshInterceptor {

    // nonisolated: accesible desde métodos nonisolated sin await (SE-0313).
    private nonisolated let keychainStore: any KeychainStoreProtocol
    private var ongoingRefresh: Task<String, Error>?

    public init(keychainStore: any KeychainStoreProtocol) {
        self.keychainStore = keychainStore
    }

    // MARK: - Acceso a tokens

    public nonisolated func accessToken() throws -> String {
        try keychainStore.loadString(for: KeychainTokenKeys.accessToken)
    }

    public nonisolated func hasValidToken() -> Bool {
        do {
            _ = try keychainStore.loadString(for: KeychainTokenKeys.accessToken)
            return true
        } catch KeychainError.itemNotFound {
            return false
        } catch {
            IFLogger.error(error, context: "TokenRefreshInterceptor.hasValidToken")
            return false
        }
    }

    // MARK: - Refresco

    /// Refresca el access token. Deduplicado: múltiples llamadas concurrentes
    /// esperan el mismo Task en lugar de disparar requests paralelos.
    public func refreshAccessToken(
        using refreshEndpoint: @escaping @Sendable (String) async throws -> (access: String, refresh: String)
    ) async throws -> String {
        if let existing = ongoingRefresh {
            return try await existing.value
        }

        guard let currentRefreshToken = try? keychainStore.loadString(for: KeychainTokenKeys.refreshToken) else {
            throw NetworkError.sessionExpired
        }

        let store = keychainStore
        let task = Task<String, Error> {
            let tokens = try await refreshEndpoint(currentRefreshToken)
            try store.saveString(tokens.access,  for: KeychainTokenKeys.accessToken)
            try store.saveString(tokens.refresh, for: KeychainTokenKeys.refreshToken)
            return tokens.access
        }

        ongoingRefresh = task
        defer { ongoingRefresh = nil }
        return try await task.value
    }

    // MARK: - Persistencia

    public nonisolated func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychainStore.saveString(accessToken,  for: KeychainTokenKeys.accessToken)
        try keychainStore.saveString(refreshToken, for: KeychainTokenKeys.refreshToken)
    }

    public nonisolated func clearTokens() {
        try? keychainStore.delete(for: KeychainTokenKeys.accessToken)
        try? keychainStore.delete(for: KeychainTokenKeys.refreshToken)
    }
}
