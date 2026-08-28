//
//  AuthRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation

public protocol AuthRepositoryProtocol: Sendable {
    /// Autentica al usuario con email y contraseña. Guarda tokens en Keychain.
    func login(email: String, password: String) async throws -> AuthSession

    /// Invalida la sesión local y notifica al servidor.
    func logout() async throws

    /// Intenta reconstruir la sesión desde Keychain. Retorna nil si no hay sesión o expiró.
    func restoreSession() async throws -> AuthSession?

    func currentUserID() async -> String?
}
