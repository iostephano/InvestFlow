//
//  LoginUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("LoginUseCase")
struct LoginUseCaseTests {

    func makeUseCase(error: Error? = nil) -> LoginUseCase {
        LoginUseCase(repository: MockAuthRepository(error: error))
    }

    // MARK: - Validación de email

    @Test func execute_emptyEmail_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "", password: "secret")
        }
    }

    @Test func execute_emailWithoutAt_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "notanemail", password: "secret")
        }
    }

    @Test func execute_emailWithoutDomain_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "user@", password: "secret")
        }
    }

    @Test func execute_emailWithoutTLD_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "user@domain", password: "secret")
        }
    }

    @Test func execute_emailWithLeadingDotInDomain_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "user@.domain.com", password: "secret")
        }
    }

    @Test func execute_emailWithLeadingWhitespace_isAccepted() async throws {
        let uc = makeUseCase()
        let session = try await uc.execute(email: "  user@investflow.com", password: "secret")
        #expect(session.userID == "user_001")
    }

    // MARK: - Validación de contraseña

    @Test func execute_emptyPassword_throwsValidation() async {
        let uc = makeUseCase()
        await #expect(throws: IFError.self) {
            try await uc.execute(email: "user@investflow.com", password: "")
        }
    }

    // MARK: - Éxito

    @Test func execute_validCredentials_returnsSession() async throws {
        let uc = makeUseCase()
        let session = try await uc.execute(email: "user@investflow.com", password: "secret")
        #expect(!session.userID.isEmpty)
        #expect(!session.accessToken.isEmpty)
    }

    // MARK: - Propagación de errores del repositorio

    @Test func execute_repositoryError_rethrows() async {
        let uc = makeUseCase(error: MockError.simulatedFailure)
        await #expect(throws: MockError.self) {
            try await uc.execute(email: "user@investflow.com", password: "secret")
        }
    }
}
