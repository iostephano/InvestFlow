//
//  AuthRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation
import FinCore

final class AuthRepositoryLive: AuthRepositoryProtocol, Sendable {

    private let apiClient:        any APIClientProtocol
    private let tokenInterceptor: TokenRefreshInterceptor
    private let keychain:         KeychainStore

    init(
        apiClient:        any APIClientProtocol,
        tokenInterceptor: TokenRefreshInterceptor,
        keychain:         KeychainStore
    ) {
        self.apiClient        = apiClient
        self.tokenInterceptor = tokenInterceptor
        self.keychain         = keychain
    }

    nonisolated func login(email: String, password: String) async throws -> AuthSession {
        do {
            let dto: LoginResponseDTO = try await apiClient.request(
                try LoginEndpoint(body: LoginRequestDTO(email: email, password: password))
            )
            try tokenInterceptor.saveTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
            try keychain.saveString(dto.userId, for: AuthKeychainKeys.userID)
            try keychain.saveString(
                String(dto.expiresAt.timeIntervalSince1970),
                for: AuthKeychainKeys.expiresAt
            )
            return AuthSession(
                userID:       dto.userId,
                accessToken:  dto.accessToken,
                refreshToken: dto.refreshToken,
                expiresAt:    dto.expiresAt
            )
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func logout() async throws {
        // Llamada al servidor best-effort — siempre limpia los tokens locales pase lo que pase
        try? await apiClient.requestVoid(LogoutEndpoint())
        tokenInterceptor.clearTokens()
        try? keychain.delete(for: AuthKeychainKeys.userID)
        try? keychain.delete(for: AuthKeychainKeys.expiresAt)
    }

    nonisolated func restoreSession() async throws -> AuthSession? {
        guard
            let accessToken  = try? tokenInterceptor.accessToken(),
            let refreshToken = try? keychain.loadString(for: KeychainTokenKeys.refreshToken),
            let storedUserID = try? keychain.loadString(for: AuthKeychainKeys.userID),
            let expiresAtStr = try? keychain.loadString(for: AuthKeychainKeys.expiresAt),
            let expiresAtTs  = TimeInterval(expiresAtStr)
        else { return nil }

        let session = AuthSession(
            userID:       storedUserID,
            accessToken:  accessToken,
            refreshToken: refreshToken,
            expiresAt:    Date(timeIntervalSince1970: expiresAtTs)
        )
        return session.isExpired ? nil : session
    }

    nonisolated func currentUserID() async -> String? {
        try? keychain.loadString(for: AuthKeychainKeys.userID)
    }
}

private nonisolated enum AuthKeychainKeys {
    static let userID    = "investflow.auth.user_id"
    static let expiresAt = "investflow.auth.expires_at"
}
