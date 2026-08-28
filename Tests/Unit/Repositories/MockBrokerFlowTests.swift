//
//  MockBrokerFlowTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

/// End-to-end: a market order placed through `OrderRepository` is visible via
/// `PortfolioRepository` once the cache is invalidated — the exact path
/// `PlaceOrderUseCase` drives in `.development`.
@Suite("MockBroker flow (Order + Portfolio)")
struct MockBrokerFlowTests {

    private func d(_ s: String) -> Decimal { Decimal(string: s)! }

    private func makeStack() -> (OrderRepository, PortfolioRepository, String) {
        let broker = MockBrokerStore()               // nuevo, en estado semilla
        let cache  = PortfolioCache()
        return (
            OrderRepository(broker: broker),
            PortfolioRepository(cache: cache, broker: broker),
            UUID().uuidString                        // userID único → sin caché compartida
        )
    }

    @Test func buy10AAPL_thenRefetchPortfolio_reflectsCashAndPosition() async throws {
        let (orderRepo, portfolioRepo, userID) = makeStack()

        let before = try await portfolioRepo.fetchPortfolio(for: userID)
        let beforeCash = before.cashBalance
        let beforeAAPL = try #require(before.positions.first { $0.instrumentID == "AAPL" }).quantity
        #expect(beforeCash == MockBrokerStore.seedCashBalance)   // 5_240
        #expect(beforeAAPL == d("10"))

        _ = try await orderRepo.placeOrder(
            OrderRequest(instrumentID: "AAPL", side: .buy, type: .market,
                         quantity: d("10"), estimatedMarketPrice: d("189.45"))
        )
        await portfolioRepo.invalidateCache(for: userID)

        let after = try await portfolioRepo.fetchPortfolio(for: userID)
        // precio de ejecución de la orden market de AAPL = OrderRepository.mockFillPrice = 189.45
        #expect(after.cashBalance == beforeCash - d("189.45") * d("10"))   // 5_240 - 1_894.50 = 3_345.50
        #expect(after.positions.first { $0.instrumentID == "AAPL" }?.quantity == d("20"))

        // El endpoint de balance de cash y el perfil del usuario concuerdan con el portafolio
        #expect(try await portfolioRepo.fetchCashBalance(for: userID) == after.cashBalance)
        #expect(try await portfolioRepo.fetchUserProfile(for: userID).cashBalance == after.cashBalance)

        // El historial de transacciones + órdenes recogió la nueva operación
        let txns = try await portfolioRepo.fetchTransactions(for: userID, limit: 50)
        #expect(txns.contains { $0.instrumentID == "AAPL" && $0.type == .buy && $0.quantity == d("10") && $0.price == d("189.45") })
        let orders = try await orderRepo.fetchOrders(for: userID, status: nil)
        #expect(orders.contains { $0.instrumentID == "AAPL" && $0.status == .filled && $0.filledQuantity == d("10") })
    }

    @Test func sellEntireAAPL_thenRefetch_positionGone() async throws {
        let (orderRepo, portfolioRepo, userID) = makeStack()

        _ = try await orderRepo.placeOrder(
            OrderRequest(instrumentID: "AAPL", side: .sell, type: .market, quantity: d("10"))
        )
        await portfolioRepo.invalidateCache(for: userID)

        let after = try await portfolioRepo.fetchPortfolio(for: userID)
        #expect(after.positions.contains { $0.instrumentID == "AAPL" } == false)
        // 5_240 + 189.45 * 10
        #expect(after.cashBalance == MockBrokerStore.seedCashBalance + d("189.45") * d("10"))
    }
}
