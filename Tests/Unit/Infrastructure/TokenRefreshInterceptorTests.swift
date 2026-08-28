//
//  TokenRefreshInterceptorTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
@testable import InvestFlow

@Suite("TokenRefreshInterceptor")
struct TokenRefreshInterceptorTests {

    @Test func accessToken_whenPresent_returnsToken() throws {
        let keychain = MockKeychainStore()
        try keychain.saveString("access_abc", for: KeychainTokenKeys.accessToken)
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)
        #expect(try interceptor.accessToken() == "access_abc")
    }

    @Test func hasValidToken_whenNoToken_returnsFalse() {
        let interceptor = TokenRefreshInterceptor(keychainStore: MockKeychainStore())
        #expect(!interceptor.hasValidToken())
    }

    @Test func hasValidToken_whenTokenPresent_returnsTrue() throws {
        let keychain = MockKeychainStore()
        try keychain.saveString("access_xyz", for: KeychainTokenKeys.accessToken)
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)
        #expect(interceptor.hasValidToken())
    }

    @Test func clearTokens_removesAccessAndRefresh() throws {
        let keychain = MockKeychainStore()
        try keychain.saveString("access", for: KeychainTokenKeys.accessToken)
        try keychain.saveString("refresh", for: KeychainTokenKeys.refreshToken)
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)
        interceptor.clearTokens()
        #expect(!interceptor.hasValidToken())
    }

    @Test func refresh_whenNoRefreshToken_throwsSessionExpired() async {
        let interceptor = TokenRefreshInterceptor(keychainStore: MockKeychainStore())
        await #expect(throws: NetworkError.sessionExpired) {
            _ = try await interceptor.refreshAccessToken { _ in ("new", "new_r") }
        }
    }

    @Test func refresh_storesNewTokensAfterSuccess() async throws {
        let keychain = MockKeychainStore()
        try keychain.saveString("old_refresh", for: KeychainTokenKeys.refreshToken)
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)

        let newToken = try await interceptor.refreshAccessToken { _ in
            ("new_access", "new_refresh")
        }

        #expect(newToken == "new_access")
        #expect(try keychain.loadString(for: KeychainTokenKeys.accessToken) == "new_access")
        #expect(try keychain.loadString(for: KeychainTokenKeys.refreshToken) == "new_refresh")
    }

    @Test func refresh_deduplicates_concurrentCalls() async throws {
        let keychain = MockKeychainStore()
        try keychain.saveString("old_refresh", for: KeychainTokenKeys.refreshToken)
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)

        // t1 es lento — t2 debe reutilizar la tarea en curso de t1 (deduplicación).
        // Ambos resultados deben ser iguales al token que produjo el closure que haya corrido.
        async let t1: String = interceptor.refreshAccessToken { _ in
            try await Task.sleep(for: .milliseconds(30))
            return (access: "token_t1", refresh: "refresh_t1")
        }
        async let t2: String = interceptor.refreshAccessToken { _ in
            return (access: "token_t2", refresh: "refresh_t2")
        }
        let (r1, r2) = try await (t1, t2)
        #expect(r1 == r2)
    }
}
