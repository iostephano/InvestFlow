//
//  PortfolioCacheTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("PortfolioCache")
struct PortfolioCacheTests {

    // Cada test usa un userID único para no compartir estado de caché
    // entre corridas de tests en paralelo contra CacheLayer.shared.

    // MARK: - guardar + cargar

    @Test func savePortfolio_thenLoad_returnsSamePortfolio() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let portfolio = Portfolio.stub(userID: userID, cashBalance: 7_777)

        await cache.savePortfolio(portfolio, for: userID)
        let loaded = await cache.loadPortfolio(for: userID)

        #expect(loaded?.userID == userID)
        #expect(loaded?.cashBalance == 7_777)
    }

    @Test func savePositions_thenLoad_returnsSamePositions() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let positions = [Position.stub(instrumentID: "AAPL"), Position.stub(instrumentID: "BTC")]

        await cache.savePositions(positions, for: userID)
        let loaded = await cache.loadPositions(for: userID)

        #expect(loaded?.count == 2)
    }

    @Test func saveTransactions_thenLoad_returnsSameCount() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let txs = [Transaction.stub(id: "t1"), Transaction.stub(id: "t2"), Transaction.stub(id: "t3")]

        await cache.saveTransactions(txs, for: userID)
        let loaded = await cache.loadTransactions(for: userID)

        #expect(loaded?.count == 3)
    }

    @Test func saveCashBalance_thenLoad_returnsCorrectBalance() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()

        await cache.saveCashBalance(Decimal(string: "9876.54")!, for: userID)
        let loaded = await cache.loadCashBalance(for: userID)

        #expect(loaded == Decimal(string: "9876.54"))
    }

    // MARK: - invalidateAll

    @Test func invalidateAll_makesPortfolioLoadReturnNil() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        await cache.savePortfolio(.stub(userID: userID), for: userID)

        await cache.invalidateAll(for: userID)
        let loaded = await cache.loadPortfolio(for: userID)

        #expect(loaded == nil)
    }

    @Test func invalidateAll_makesPositionsLoadReturnNil() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        await cache.savePositions([.stub()], for: userID)

        await cache.invalidateAll(for: userID)
        let loaded = await cache.loadPositions(for: userID)

        #expect(loaded == nil)
    }

    @Test func invalidateAll_makesCashBalanceLoadReturnNil() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        await cache.saveCashBalance(1000, for: userID)

        await cache.invalidateAll(for: userID)
        let loaded = await cache.loadCashBalance(for: userID)

        #expect(loaded == nil)
    }

    @Test func invalidateAll_onlyAffectsTargetUser() async {
        let userA = UUID().uuidString
        let userB = UUID().uuidString
        let cache = PortfolioCache()
        await cache.savePortfolio(.stub(userID: userA), for: userA)
        await cache.savePortfolio(.stub(userID: userB), for: userB)

        await cache.invalidateAll(for: userA)

        let loadedA = await cache.loadPortfolio(for: userA)
        let loadedB = await cache.loadPortfolio(for: userB)
        #expect(loadedA == nil)
        #expect(loadedB != nil)
    }

    // MARK: - Expiración de TTL (vía CacheLayer directamente)

    @Test func cacheLayer_expiredEntry_returnsNil() async {
        let key = "ttl-test-\(UUID().uuidString)"

        // ttl = -1 → la entrada ya venció
        await CacheLayer.shared.set(Portfolio.stub(), for: key, ttl: -1)
        let result: Portfolio? = await CacheLayer.shared.get(key)

        #expect(result == nil)
    }

    @Test func cacheLayer_freshEntry_returnsValue() async {
        let key = "ttl-fresh-\(UUID().uuidString)"

        await CacheLayer.shared.set("sentinel", for: key, ttl: 300)
        let result: String? = await CacheLayer.shared.get(key)

        #expect(result == "sentinel")

        // Limpieza
        await CacheLayer.shared.remove(for: key)
    }

    // MARK: - Concurrencia

    @Test func twoConsecutiveSaves_lastWriteWins() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()
        let first  = Portfolio.stub(userID: userID, cashBalance: 100)
        let second = Portfolio.stub(userID: userID, cashBalance: 999)

        await cache.savePortfolio(first, for: userID)
        await cache.savePortfolio(second, for: userID)
        let loaded = await cache.loadPortfolio(for: userID)

        #expect(loaded?.cashBalance == 999)
    }

    @Test func loadBeforeSave_returnsNil() async {
        let userID = UUID().uuidString
        let cache = PortfolioCache()

        let loaded = await cache.loadPortfolio(for: userID)

        #expect(loaded == nil)
    }
}
