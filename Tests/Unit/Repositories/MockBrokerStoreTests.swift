//
//  MockBrokerStoreTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("MockBrokerStore")
struct MockBrokerStoreTests {

    // Auxiliares ------------------------------------------------------------

    private func d(_ s: String) -> Decimal { Decimal(string: s)! }

    private func store(
        cash: String = "10000",
        positions: [Position] = []
    ) -> MockBrokerStore {
        MockBrokerStore(cashBalance: d(cash), positions: positions, orders: [], transactions: [])
    }

    private func marketBuy(_ id: String, _ qty: String) -> OrderRequest {
        OrderRequest(instrumentID: id, side: .buy, type: .market, quantity: d(qty))
    }

    private func marketSell(_ id: String, _ qty: String) -> OrderRequest {
        OrderRequest(instrumentID: id, side: .sell, type: .market, quantity: d(qty))
    }

    private func position(_ id: String, type: InstrumentType = .stock, qty: String, avg: String, price: String) -> Position {
        Position(instrumentID: id, instrumentType: type, quantity: d(qty), averageCostBasis: d(avg), currentPrice: d(price))
    }

    // 1. Comprar un instrumento sin posición previa ----------------------------

    @Test func buy_newInstrument_createsPositionAtFillPrice() async throws {
        let s = store(cash: "10000")

        _ = try await s.applyOrder(marketBuy("TSLA", "3"), fillPrice: d("248.12"))

        let positions = await s.currentPositions()
        let tsla = try #require(positions.first { $0.instrumentID == "TSLA" })
        #expect(tsla.quantity == d("3"))
        #expect(tsla.averageCostBasis == d("248.12"))
        #expect(tsla.currentPrice == d("248.12"))
        #expect(tsla.instrumentType == .stock)
    }

    @Test func buy_newCrypto_getsCryptoInstrumentType() async throws {
        let s = store()
        _ = try await s.applyOrder(marketBuy("ETH", "1"), fillPrice: d("3000"))
        let eth = try #require(await s.currentPositions().first { $0.instrumentID == "ETH" })
        #expect(eth.instrumentType == .crypto)
    }

    // 2. Comprar más de una posición existente → promedio ponderado por cantidad

    @Test func buy_existingInstrument_sumsQuantityAndBlendsAverageCost() async throws {
        let s = store(cash: "10000", positions: [position("AAPL", qty: "10", avg: "100", price: "120")])

        _ = try await s.applyOrder(marketBuy("AAPL", "10"), fillPrice: d("200"))

        let aapl = try #require(await s.currentPositions().first { $0.instrumentID == "AAPL" })
        #expect(aapl.quantity == d("20"))
        // (10*100 + 10*200) / 20 = 150
        #expect(aapl.averageCostBasis == d("150"))
        // currentPrice (precio de mercado) no lo sobrescribe una ejecución
        #expect(aapl.currentPrice == d("120"))
    }

    // 3. Vender la posición completa → desaparece -----------------------------

    @Test func sell_entirePosition_removesItFromPortfolio() async throws {
        let s = store(cash: "1000", positions: [position("SPY", type: .etf, qty: "5", avg: "490", price: "524.80")])

        _ = try await s.applyOrder(marketSell("SPY", "5"), fillPrice: d("524.80"))

        #expect(await s.currentPositions().contains { $0.instrumentID == "SPY" } == false)
    }

    // 4. Vender parte de una posición → baja la cantidad, la posición queda ---

    @Test func sell_partialPosition_reducesQuantityKeepsAverageCost() async throws {
        let s = store(cash: "1000", positions: [position("SPY", type: .etf, qty: "5", avg: "490", price: "524.80")])

        _ = try await s.applyOrder(marketSell("SPY", "2"), fillPrice: d("524.80"))

        let spy = try #require(await s.currentPositions().first { $0.instrumentID == "SPY" })
        #expect(spy.quantity == d("3"))
        #expect(spy.averageCostBasis == d("490"))
    }

    // 5. El cash se mueve por precio × cantidad ------------------------------

    @Test func buy_reducesCashByNotional() async throws {
        let s = store(cash: "10000")
        _ = try await s.applyOrder(marketBuy("AAPL", "10"), fillPrice: d("189.45"))
        // 10000 - (189.45 * 10)
        #expect(await s.currentCashBalance() == d("8105.50"))
    }

    @Test func sell_increasesCashByNotional() async throws {
        let s = store(cash: "1000", positions: [position("AAPL", qty: "10", avg: "150", price: "189.45")])
        _ = try await s.applyOrder(marketSell("AAPL", "4"), fillPrice: d("189.45"))
        // 1000 + (189.45 * 4)
        #expect(await s.currentCashBalance() == d("1757.80"))
    }

    // 6. Dos compras consecutivas — la segunda ve el balance reducido --------

    @Test func consecutiveBuys_secondValidatesAgainstReducedBalance() async throws {
        let s = store(cash: "4000")

        _ = try await s.applyOrder(marketBuy("AAPL", "10"), fillPrice: d("189.45"))   // -1894.50 → 2105.50
        #expect(await s.currentCashBalance() == d("2105.50"))

        _ = try await s.applyOrder(marketBuy("AAPL", "10"), fillPrice: d("189.45"))   // -1894.50 → 211.00
        #expect(await s.currentCashBalance() == d("211.00"))

        // La tercera compra necesita 1894.50 pero solo quedan 211.00 → rechazada contra el balance *actual*
        await #expect(throws: IFError.self) {
            _ = try await s.applyOrder(self.marketBuy("AAPL", "10"), fillPrice: self.d("189.45"))
        }
        #expect(await s.currentCashBalance() == d("211.00"))   // sin cambios tras la compra fallida
        let aapl = try #require(await s.currentPositions().first { $0.instrumentID == "AAPL" })
        #expect(aapl.quantity == d("20"))                       // solo las dos compras exitosas
    }

    // 7. El historial de órdenes + transacciones refleja las nuevas operaciones

    @Test func applyOrder_appendsOrderAndTransactionToHistory() async throws {
        let s = store(cash: "10000")

        let order = try await s.applyOrder(marketBuy("AAPL", "10"), fillPrice: d("189.45"))

        let orders = await s.currentOrders()
        #expect(orders.first?.id == order.id)
        #expect(orders.first?.status == .filled)
        #expect(orders.first?.filledQuantity == d("10"))
        #expect(orders.first?.averageFillPrice == d("189.45"))

        let txns = await s.currentTransactions()
        #expect(txns.first?.orderID == order.id)
        #expect(txns.first?.type == .buy)
        #expect(txns.first?.quantity == d("10"))
        #expect(txns.first?.price == d("189.45"))
    }

    // 8. Vender de más se rechaza -----------------------------------------

    @Test func sell_moreThanHeld_throwsAndLeavesStateUnchanged() async throws {
        let s = store(cash: "1000", positions: [position("SPY", type: .etf, qty: "5", avg: "490", price: "524.80")])

        await #expect(throws: IFError.self) {
            _ = try await s.applyOrder(self.marketSell("SPY", "10"), fillPrice: self.d("524.80"))
        }
        #expect(await s.currentCashBalance() == d("1000"))
        #expect(await s.currentPositions().first { $0.instrumentID == "SPY" }?.quantity == d("5"))
    }

    @Test func sell_instrumentNotHeld_throws() async throws {
        let s = store(cash: "1000")
        await #expect(throws: IFError.self) {
            _ = try await s.applyOrder(self.marketSell("NVDA", "1"), fillPrice: self.d("100"))
        }
    }

    // 9. Órdenes no-market: se registran pending, sin impacto en cash / posición / txn

    @Test func limitOrder_isPending_withNoBalanceOrPositionImpact() async throws {
        let s = store(cash: "10000")
        let req = OrderRequest(instrumentID: "AAPL", side: .buy, type: .limit, quantity: d("5"), limitPrice: d("150"))

        let order = try await s.applyOrder(req, fillPrice: d("150"))

        #expect(order.status == .pending)
        #expect(order.filledQuantity == .zero)
        #expect(await s.currentCashBalance() == d("10000"))
        #expect(await s.currentPositions().isEmpty)
        #expect(await s.currentTransactions().isEmpty)
        #expect(await s.currentOrders().first?.id == order.id)   // igual queda registrada
    }

    // 10. Una instancia nueva vuelve al estado semilla --------------------
    //     (documenta: el mock no persiste entre relanzamientos de la app)

    @Test func freshInstance_startsFromSeedValues() async {
        let s = MockBrokerStore()
        #expect(await s.currentCashBalance() == MockBrokerStore.seedCashBalance)
        #expect(await s.currentPositions().count == 4)
        #expect(await s.currentOrders().count == 4)
        #expect(await s.currentTransactions().count == 5)
    }

    @Test func reset_restoresSeedState() async throws {
        let s = MockBrokerStore()
        _ = try await s.applyOrder(marketBuy("AAPL", "5"), fillPrice: d("189.45"))
        await s.reset()
        #expect(await s.currentCashBalance() == MockBrokerStore.seedCashBalance)
        #expect(await s.currentPositions().count == 4)
    }

    // Cantidad cero / inválida ------------------------------------------

    @Test func applyOrder_zeroQuantity_throws() async {
        let s = store()
        await #expect(throws: IFError.self) {
            _ = try await s.applyOrder(OrderRequest(instrumentID: "AAPL", side: .buy, type: .market, quantity: .zero), fillPrice: self.d("100"))
        }
    }
}
