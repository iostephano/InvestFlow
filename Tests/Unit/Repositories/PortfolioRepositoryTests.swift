//
//  PortfolioRepositoryTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("PortfolioRepository")
struct PortfolioRepositoryTests {

    // Cada test usa un userID único para que los tests en paralelo no compartan estado de CacheLayer.

    // MARK: - Cache miss → fetch → caché poblada

    @Test func firstFetch_returnsMockPortfolio() async throws {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let repo  = PortfolioRepository(cache: cache)

        let portfolio = try await repo.fetchPortfolio(for: userID)

        #expect(portfolio.userID == userID)
        #expect(!portfolio.positions.isEmpty)
    }

    @Test func firstFetch_populatesCache() async throws {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let repo  = PortfolioRepository(cache: cache)

        _ = try await repo.fetchPortfolio(for: userID)
        let cached = await cache.loadPortfolio(for: userID)

        #expect(cached != nil)
    }

    // MARK: - Cache hit → sin re-fetch

    @Test func secondFetch_returnsCachedPortfolio() async throws {
        let userID = UUID().uuidString
        let cache  = PortfolioCache()
        // Pre-sembrar la caché con un portafolio distinguible
        let seeded = Portfolio.stub(userID: userID, cashBalance: 42_000)
        await cache.savePortfolio(seeded, for: userID)

        let repo   = PortfolioRepository(cache: cache)
        let result = try await repo.fetchPortfolio(for: userID)

        // El repositorio debe devolver el valor cacheado, no su propio mock
        #expect(result.cashBalance == 42_000)
    }

    @Test func secondFetchTransactions_returnsCachedData() async throws {
        let userID = UUID().uuidString
        let cache  = PortfolioCache()
        let seeded = [Transaction.stub(id: "cached-tx-1"), Transaction.stub(id: "cached-tx-2")]
        await cache.saveTransactions(seeded, for: userID)

        let repo   = PortfolioRepository(cache: cache)
        let result = try await repo.fetchTransactions(for: userID, limit: 20)

        #expect(result.count == 2)
        #expect(result.first?.id == "cached-tx-1")
    }

    @Test func secondFetchCashBalance_returnsCachedBalance() async throws {
        let userID = UUID().uuidString
        let cache  = PortfolioCache()
        await cache.saveCashBalance(Decimal(string: "12_345.00")!, for: userID)

        let repo   = PortfolioRepository(cache: cache)
        let result = try await repo.fetchCashBalance(for: userID)

        #expect(result == Decimal(string: "12_345.00"))
    }

    // MARK: - invalidateCache → el siguiente fetch es un miss

    @Test func invalidateCache_nextFetchIsMiss() async throws {
        let userID = UUID().uuidString
        let cache  = PortfolioCache()
        let repo   = PortfolioRepository(cache: cache)

        // El primer fetch puebla la caché
        _ = try await repo.fetchPortfolio(for: userID)
        #expect(await cache.loadPortfolio(for: userID) != nil)

        // Invalidar
        await repo.invalidateCache(for: userID)

        // La caché ahora debe estar vacía
        #expect(await cache.loadPortfolio(for: userID) == nil)
    }

    @Test func afterInvalidate_nextFetchRepopulatesCache() async throws {
        let userID = UUID().uuidString
        let cache  = PortfolioCache()
        let repo   = PortfolioRepository(cache: cache)

        _ = try await repo.fetchPortfolio(for: userID)
        await repo.invalidateCache(for: userID)

        // El siguiente fetch debe tener éxito y volver a poblar la caché
        let portfolio = try await repo.fetchPortfolio(for: userID)
        #expect(portfolio.userID == userID)
        #expect(await cache.loadPortfolio(for: userID) != nil)
    }

    // MARK: - Posiciones y transacciones

    @Test func fetchPositions_firstCall_returnsNonEmptyList() async throws {
        let userID = UUID().uuidString
        let repo = PortfolioRepository(cache: PortfolioCache())

        let positions = try await repo.fetchPositions(for: userID)

        #expect(!positions.isEmpty)
    }

    @Test func fetchTransactions_limitsResultCount() async throws {
        let userID = UUID().uuidString
        let repo = PortfolioRepository(cache: PortfolioCache())

        let all     = try await repo.fetchTransactions(for: userID, limit: 100)
        let limited = try await repo.fetchTransactions(for: userID, limit: 2)

        // "All" devuelve el set mock completo, "limited" respeta el tope
        #expect(all.count >= limited.count)
        #expect(limited.count <= 2)
    }
}
