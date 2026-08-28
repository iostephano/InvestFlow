//
//  PortfolioRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

/// Repositorio de portafolio mock para el entorno `.development`.
///
/// Las posiciones, el cash, las transacciones y el estado derivado de órdenes
/// vienen de `MockBrokerStore` — el mismo actor sobre el que escribe `OrderRepository` —
/// así que una compra o venta hecha en una pantalla se refleja en todo el resto de
/// la sesión. `PortfolioCache` sigue delante (TTL de 5 minutos); `invalidateCache` la
/// limpia y el siguiente fetch trae el estado *actual* del broker en lugar de una
/// constante fija.
public final class PortfolioRepository: PortfolioRepositoryProtocol, Sendable {

    private let cache: PortfolioCache
    private let broker: MockBrokerStore

    public init(cache: PortfolioCache = PortfolioCache(), broker: MockBrokerStore = .shared) {
        self.cache = cache
        self.broker = broker
    }

    // MARK: - PortfolioRepositoryProtocol

    public func fetchPortfolio(for userID: String) async throws -> Portfolio {
        if let cached = await cache.loadPortfolio(for: userID) {
            return cached
        }
        try await Task.sleep(for: .milliseconds(130))
        let portfolio = await broker.currentPortfolio(for: userID)
        await cache.savePortfolio(portfolio, for: userID)
        return portfolio
    }

    public func fetchPositions(for userID: String) async throws -> [Position] {
        if let cached = await cache.loadPositions(for: userID) {
            return cached
        }
        try await Task.sleep(for: .milliseconds(100))
        let positions = await broker.currentPositions()
        await cache.savePositions(positions, for: userID)
        return positions
    }

    public func fetchTransactions(for userID: String, limit: Int) async throws -> [Transaction] {
        if let cached = await cache.loadTransactions(for: userID) {
            return Array(cached.prefix(limit))
        }
        try await Task.sleep(for: .milliseconds(110))
        let transactions = await broker.currentTransactions()
        await cache.saveTransactions(transactions, for: userID)
        return Array(transactions.prefix(limit))
    }

    public func fetchCashBalance(for userID: String) async throws -> Decimal {
        if let cached = await cache.loadCashBalance(for: userID) {
            return cached
        }
        try await Task.sleep(for: .milliseconds(60))
        let balance = await broker.currentCashBalance()
        await cache.saveCashBalance(balance, for: userID)
        return balance
    }

    public func fetchUserProfile(for userID: String) async throws -> UserProfile {
        if let cached = await cache.loadUserProfile(for: userID) { return cached }
        try await Task.sleep(for: .milliseconds(80))
        let profile = Self.mockUserProfile(id: userID, cashBalance: await broker.currentCashBalance())
        await cache.saveUserProfile(profile, for: userID)
        return profile
    }

    public func invalidateCache(for userID: String) async {
        await cache.invalidateAll(for: userID)
    }
}

// MARK: - Datos mock

private extension PortfolioRepository {

    /// Los campos del perfil que no son cash son fijos; `cashBalance` sigue el estado vivo del broker.
    static func mockUserProfile(id: String, cashBalance: Decimal) -> UserProfile {
        UserProfile(
            id:          id,
            email:       "usuario@investflow.com",
            firstName:   "Rodrigo",
            lastName:    "Salas",
            kycStatus:   .approved,
            riskProfile: .moderate,
            cashBalance: cashBalance,
            currency:    .usd,
            createdAt:   Date().addingTimeInterval(-86_400 * 90)
        )
    }
}
