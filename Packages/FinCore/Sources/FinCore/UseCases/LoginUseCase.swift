//
//  LoginUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct LoginUseCase: Sendable {

    private let repository: any AuthRepositoryProtocol

    public init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> AuthSession {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        let parts   = trimmed.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, parts[1].contains("."), !parts[1].hasPrefix(".") else {
            throw IFError.validationFailed("Ingresa un email válido.")
        }
        guard !password.isEmpty else {
            throw IFError.validationFailed("La contraseña no puede estar vacía.")
        }
        return try await repository.login(email: email, password: password)
    }
}
