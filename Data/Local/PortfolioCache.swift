//
//  PortfolioCache.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

/// Cache local del portafolio con TTL de 5 minutos.
/// Reduce requests redundantes cuando el usuario navega entre pantallas.
public actor PortfolioCache {

    private let cache: CacheLayer
    private let portfolioTTL: TimeInterval   = 300     // 5 min
    private let positionsTTL: TimeInterval   = 300
    private let transactionsTTL: TimeInterval = 600  // 10 min — cambia menos frecuente
    private let cashBalanceTTL: TimeInterval  = 300
    private let userProfileTTL: TimeInterval  = 300  // 5 min — mismo ciclo que portfolio

    public init(cache: CacheLayer = .shared) {
        self.cache = cache
    }

    // MARK: - Portafolio

    public func savePortfolio(_ portfolio: Portfolio, for userID: String) async {
        await cache.set(portfolio, for: portfolioKey(userID), ttl: portfolioTTL)
    }

    public func loadPortfolio(for userID: String) async -> Portfolio? {
        await cache.get(portfolioKey(userID))
    }

    // MARK: - Posiciones

    public func savePositions(_ positions: [Position], for userID: String) async {
        await cache.set(positions, for: positionsKey(userID), ttl: positionsTTL)
    }

    public func loadPositions(for userID: String) async -> [Position]? {
        await cache.get(positionsKey(userID))
    }

    // MARK: - Transacciones

    public func saveTransactions(_ transactions: [Transaction], for userID: String) async {
        await cache.set(transactions, for: transactionsKey(userID), ttl: transactionsTTL)
    }

    public func loadTransactions(for userID: String) async -> [Transaction]? {
        await cache.get(transactionsKey(userID))
    }

    // MARK: - Balance de cash

    public func saveCashBalance(_ balance: Decimal, for userID: String) async {
        await cache.set(balance, for: cashBalanceKey(userID), ttl: cashBalanceTTL)
    }

    public func loadCashBalance(for userID: String) async -> Decimal? {
        await cache.get(cashBalanceKey(userID))
    }

    // MARK: - UserProfile

    public func saveUserProfile(_ profile: UserProfile, for userID: String) async {
        await cache.set(profile, for: userProfileKey(userID), ttl: userProfileTTL)
    }

    public func loadUserProfile(for userID: String) async -> UserProfile? {
        await cache.get(userProfileKey(userID))
    }

    // MARK: - Invalidación

    public func invalidateAll(for userID: String) async {
        await cache.remove(for: portfolioKey(userID))
        await cache.remove(for: positionsKey(userID))
        await cache.remove(for: transactionsKey(userID))
        await cache.remove(for: cashBalanceKey(userID))
        await cache.remove(for: userProfileKey(userID))
    }

    // MARK: - Claves

    private func portfolioKey(_ userID: String)    -> String { "portfolio_\(userID)" }
    private func positionsKey(_ userID: String)    -> String { "positions_\(userID)" }
    private func transactionsKey(_ userID: String) -> String { "transactions_\(userID)" }
    private func cashBalanceKey(_ userID: String)  -> String { "cash_balance_\(userID)" }
    private func userProfileKey(_ userID: String)  -> String { "user_profile_\(userID)" }
}
