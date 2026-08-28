//
//  PortfolioRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation
import FinCore

final class PortfolioRepositoryLive: PortfolioRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol
    private let cache: PortfolioCache

    init(apiClient: any APIClientProtocol, cache: PortfolioCache = PortfolioCache()) {
        self.apiClient = apiClient
        self.cache = cache
    }

    nonisolated func fetchPortfolio(for userID: String) async throws -> Portfolio {
        if let cached = await cache.loadPortfolio(for: userID) { return cached }
        do {
            let dto: PortfolioDTO = try await apiClient.request(GetPortfolioEndpoint(userID: userID))
            guard let portfolio = PortfolioMapper.map(dto) else {
                throw IFError.notFound("portafolio del usuario")
            }
            await cache.savePortfolio(portfolio, for: userID)
            return portfolio
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchPositions(for userID: String) async throws -> [Position] {
        if let cached = await cache.loadPositions(for: userID) { return cached }
        do {
            let dtos: [PositionDTO] = try await apiClient.request(GetPositionsEndpoint(userID: userID))
            let positions = PositionMapper.map(dtos)
            await cache.savePositions(positions, for: userID)
            return positions
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchTransactions(for userID: String, limit: Int) async throws -> [Transaction] {
        if let cached = await cache.loadTransactions(for: userID) { return cached }
        do {
            let dtos: [TransactionDTO] = try await apiClient.request(
                GetTransactionsEndpoint(userID: userID, limit: limit)
            )
            let transactions = TransactionMapper.map(dtos)
            await cache.saveTransactions(transactions, for: userID)
            return transactions
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchCashBalance(for userID: String) async throws -> Decimal {
        if let cached = await cache.loadCashBalance(for: userID) { return cached }
        do {
            let dto: UserProfileDTO = try await apiClient.request(GetUserProfileEndpoint(userID: userID))
            guard let balance = Decimal(string: dto.cashBalance) else {
                throw IFError.unknown("cashBalance inválido en la respuesta del servidor")
            }
            await cache.saveCashBalance(balance, for: userID)
            return balance
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchUserProfile(for userID: String) async throws -> UserProfile {
        if let cached = await cache.loadUserProfile(for: userID) { return cached }
        do {
            let dto: UserProfileDTO = try await apiClient.request(GetUserProfileEndpoint(userID: userID))
            guard let profile = UserProfileMapper.map(dto) else {
                throw IFError.notFound("perfil del usuario")
            }
            await cache.saveUserProfile(profile, for: userID)
            return profile
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func invalidateCache(for userID: String) async {
        await cache.invalidateAll(for: userID)
    }
}
