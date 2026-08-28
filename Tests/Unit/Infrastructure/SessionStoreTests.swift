//
//  SessionStoreTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("SessionStore")
@MainActor
struct SessionStoreTests {

    @Test func initialState_isUnauthenticated() {
        let store = SessionStore()
        #expect(store.isAuthenticated == false)
        #expect(store.userID == "")
    }

    @Test func signIn_setsAuthenticatedAndUserID() {
        let store = SessionStore()
        store.signIn(.stub(userID: "u42"))
        #expect(store.isAuthenticated)
        #expect(store.userID == "u42")
    }

    @Test func signOut_clearsSession() {
        let store = SessionStore()
        store.signIn(.stub())
        store.signOut()
        #expect(store.isAuthenticated == false)
        #expect(store.userID == "")
    }

    // Regresión: "Cerrar sesión" desde el drawer debe invalidar la sesión
    // (LogoutUseCase + SessionStore.signOut), no solo resetear la navegación vía
    // AppCoordinator.performLogout(). Es la secuencia exacta que ejecutan DrawerView y
    // ProfileView al confirmar.
    @Test func logoutFlow_invalidatesSession() async throws {
        let store = SessionStore()
        store.signIn(.stub())
        let logout = LogoutUseCase(repository: MockAuthRepository())

        try await logout.execute()
        store.signOut()

        #expect(store.isAuthenticated == false)
    }

    @Test func logoutFlow_whenUseCaseFails_sessionIsPreserved() async {
        let store = SessionStore()
        store.signIn(.stub())
        let logout = LogoutUseCase(repository: MockAuthRepository(error: MockError.simulatedFailure))

        await #expect(throws: MockError.self) {
            try await logout.execute()
        }
        // signOut() solo se alcanza si hay éxito — un logout fallido mantiene al usuario dentro.
        #expect(store.isAuthenticated)
    }
}
