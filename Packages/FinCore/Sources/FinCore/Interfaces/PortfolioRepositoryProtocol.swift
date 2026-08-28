//
//  PortfolioRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public protocol PortfolioRepositoryProtocol: Sendable {
    func fetchPortfolio(for userID: String) async throws -> Portfolio

    /// Devuelve solo las posiciones abiertas del usuario.
    func fetchPositions(for userID: String) async throws -> [Position]

    /// - Parameter limit: Máximo de registros a devolver (default 50).
    func fetchTransactions(for userID: String, limit: Int) async throws -> [Transaction]

    func fetchCashBalance(for userID: String) async throws -> Decimal

    func fetchUserProfile(for userID: String) async throws -> UserProfile

    /// Invalida el cache local del portafolio del usuario.
    /// Llamar después de cualquier operación que modifique posiciones o cash.
    func invalidateCache(for userID: String) async
}
