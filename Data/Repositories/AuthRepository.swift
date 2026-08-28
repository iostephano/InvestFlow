//
//  AuthRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation
import FinCore

final class AuthRepository: AuthRepositoryProtocol, Sendable {

    private let keychain: KeychainStore

    init(keychain: KeychainStore = KeychainStore()) {
        self.keychain = keychain
    }

    nonisolated func login(email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(200))
        let session = AuthSession(
            userID:       "user_001",
            accessToken:  "mock_access_\(UUID().uuidString)",
            refreshToken: "mock_refresh_\(UUID().uuidString)",
            expiresAt:    Date().addingTimeInterval(3600)
        )
        try persistSession(session)
        return session
    }

    nonisolated func logout() async throws {
        clearSession()
    }

    nonisolated func restoreSession() async throws -> AuthSession? {
        guard
            let accessToken  = try? keychain.loadString(for: KeychainTokenKeys.accessToken),
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

    private nonisolated func persistSession(_ session: AuthSession) throws {
        try keychain.saveString(session.accessToken,  for: KeychainTokenKeys.accessToken)
        try keychain.saveString(session.refreshToken, for: KeychainTokenKeys.refreshToken)
        try keychain.saveString(session.userID,       for: AuthKeychainKeys.userID)
        let ts = String(session.expiresAt.timeIntervalSince1970)
        try keychain.saveString(ts, for: AuthKeychainKeys.expiresAt)
    }

    private nonisolated func clearSession() {
        try? keychain.delete(for: KeychainTokenKeys.accessToken)
        try? keychain.delete(for: KeychainTokenKeys.refreshToken)
        try? keychain.delete(for: AuthKeychainKeys.userID)
        try? keychain.delete(for: AuthKeychainKeys.expiresAt)
    }
}

private nonisolated enum AuthKeychainKeys {
    static let userID    = "investflow.auth.user_id"
    static let expiresAt = "investflow.auth.expires_at"
}
