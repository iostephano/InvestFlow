//
//  LoginViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {

    func makeViewModel(error: Error? = nil) -> LoginViewModel {
        LoginViewModel(
            loginUseCase: LoginUseCase(repository: MockAuthRepository(error: error)),
            onSuccess: { _ in }
        )
    }

    // MARK: - Estado inicial

    @Test func initialState_canLoginIsFalse() {
        let vm = makeViewModel()
        #expect(!vm.canLogin)
    }

    @Test func initialState_isNotLoading() {
        let vm = makeViewModel()
        #expect(!vm.isLoading)
    }

    @Test func initialState_noErrorMessage() {
        let vm = makeViewModel()
        #expect(vm.errorMessage == nil)
    }

    // MARK: - Compuerta de canLogin

    @Test func canLogin_withEmailOnly_isFalse() {
        let vm = makeViewModel()
        vm.email = "user@investflow.com"
        #expect(!vm.canLogin)
    }

    @Test func canLogin_withPasswordOnly_isFalse() {
        let vm = makeViewModel()
        vm.password = "secret"
        #expect(!vm.canLogin)
    }

    @Test func canLogin_withEmailAndPassword_isTrue() {
        let vm = makeViewModel()
        vm.email = "user@investflow.com"
        vm.password = "secret"
        #expect(vm.canLogin)
    }

    @Test func canLogin_withWhitespaceOnlyEmail_isFalse() {
        let vm = makeViewModel()
        vm.email = "   "
        vm.password = "secret"
        #expect(!vm.canLogin)
    }

    // MARK: - Login exitoso

    @Test func login_success_callsOnSuccess() async throws {
        var receivedSession: AuthSession?
        let vm = LoginViewModel(
            loginUseCase: LoginUseCase(repository: MockAuthRepository()),
            onSuccess: { session in receivedSession = session }
        )
        vm.email    = "user@investflow.com"
        vm.password = "secret"

        await vm.login()

        #expect(receivedSession != nil)
        #expect(receivedSession?.userID == "user_001")
    }

    // MARK: - Login fallido

    @Test func login_failure_stateIsFailed() async throws {
        let vm = makeViewModel(error: MockError.simulatedFailure)
        vm.email    = "user@investflow.com"
        vm.password = "secret"

        await vm.login()

        #expect(vm.errorMessage != nil)
        #expect(!vm.isLoading)
    }

    @Test func login_failure_onSuccessNotCalled() async throws {
        var called = false
        let vm = LoginViewModel(
            loginUseCase: LoginUseCase(repository: MockAuthRepository(error: MockError.simulatedFailure)),
            onSuccess: { _ in called = true }
        )
        vm.email    = "user@investflow.com"
        vm.password = "secret"

        await vm.login()

        #expect(!called)
    }

    // MARK: - canLogin bloqueado durante la carga

    @Test func login_afterCompletion_isNotLoading() async throws {
        let vm = makeViewModel()
        vm.email    = "user@investflow.com"
        vm.password = "secret"

        await vm.login()

        #expect(!vm.isLoading)
    }
}
