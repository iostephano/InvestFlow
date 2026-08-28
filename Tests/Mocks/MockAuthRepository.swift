//
//  MockAuthRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

struct MockAuthRepository: AuthRepositoryProtocol {

    let session: AuthSession?
    let error: Error?
    let storedUserID: String?

    init(
        session: AuthSession? = .stub(),
        error: Error? = nil,
        storedUserID: String? = "user_001"
    ) {
        self.session = session
        self.error = error
        self.storedUserID = storedUserID
    }

    func login(email: String, password: String) async throws -> AuthSession {
        if let error { throw error }
        return session ?? AuthSession.stub()
    }

    func logout() async throws {
        if let error { throw error }
    }

    func restoreSession() async throws -> AuthSession? {
        if let error { throw error }
        return session
    }

    func currentUserID() async -> String? {
        storedUserID
    }
}

extension AuthSession {
    nonisolated static func stub(
        userID: String = "user_001",
        expiresAt: Date = Date().addingTimeInterval(3600)
    ) -> AuthSession {
        AuthSession(
            userID:       userID,
            accessToken:  "mock_access_token",
            refreshToken: "mock_refresh_token",
            expiresAt:    expiresAt
        )
    }
}
