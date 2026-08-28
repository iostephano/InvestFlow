//
//  PlaceOrderUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("PlaceOrderUseCase")
struct PlaceOrderUseCaseTests {

    func makeUseCase(cashBalance: Decimal = 10_000) -> PlaceOrderUseCase {
        PlaceOrderUseCase(
            orderRepository: MockOrderRepository(orderToReturn: .stub()),
            portfolioRepository: MockPortfolioRepository(cashBalance: cashBalance)
        )
    }

    // MARK: - Validación de cantidad

    @Test func givenZeroQuantity_whenPlacingOrder_thenThrowsInvalidQuantity() async throws {
        let request = OrderRequest(instrumentID: "AAPL", side: .buy, type: .market, quantity: .zero)

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    @Test func givenNegativeQuantity_whenPlacingOrder_thenThrowsInvalidQuantity() async throws {
        let request = OrderRequest(instrumentID: "AAPL", side: .buy, type: .market, quantity: -1)

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    // MARK: - Validación de precio límite

    @Test func givenLimitOrderWithoutLimitPrice_whenPlacingOrder_thenThrowsMissingLimitPrice() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .limit,
            quantity: 5,
            limitPrice: nil
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    @Test func givenStopLimitOrderWithoutLimitPrice_whenPlacingOrder_thenThrowsMissingLimitPrice() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLimit,
            quantity: 5,
            limitPrice: nil,
            stopPrice: 140
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    // MARK: - Validación de precio stop

    @Test func givenStopLossOrderWithoutStopPrice_whenPlacingOrder_thenThrowsMissingStopPrice() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLoss,
            quantity: 5,
            stopPrice: nil
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    @Test func givenStopLossOrderWithStopPrice_whenSufficientFunds_thenReturnsOrder() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLoss,
            quantity: 5,
            stopPrice: 150
        )

        let order = try await makeUseCase(cashBalance: 10_000).execute(request, userID: "u1")

        #expect(order.instrumentID == "AAPL")
    }

    @Test func givenStopLimitOrderWithoutStopPrice_whenPlacingOrder_thenThrowsMissingStopPrice() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLimit,
            quantity: 5,
            limitPrice: 145,
            stopPrice: nil
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    @Test func givenStopLimitOrderWithZeroStopPrice_whenPlacingOrder_thenThrows() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLimit,
            quantity: 5,
            limitPrice: 145,
            stopPrice: .zero
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase().execute(request, userID: "u1")
        }
    }

    @Test func givenStopLimitOrderWithBothPrices_whenSufficientFunds_thenReturnsOrder() async throws {
        // stopPrice se activa en 148, ejecuta a limitPrice 145
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLimit,
            quantity: 5,
            limitPrice: 145,
            stopPrice: 148
        )

        let order = try await makeUseCase(cashBalance: 10_000).execute(request, userID: "u1")

        #expect(order.instrumentID == "AAPL")
    }

    @Test func givenStopLimitOrderWithBothPrices_whenInsufficientFunds_thenThrows() async throws {
        // limitPrice 145 * qty 10 = 1450, cash 500 → insuficiente
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .stopLimit,
            quantity: 10,
            limitPrice: 145,
            stopPrice: 148
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase(cashBalance: 500).execute(request, userID: "u1")
        }
    }

    // MARK: - Fondos insuficientes

    @Test func givenBuyMarketOrder_whenInsufficientFunds_thenThrowsInsufficientFunds() async throws {
        // estimado = 200 * 10 = 2000, cash = 500 → insuficiente
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .market,
            quantity: 10,
            estimatedMarketPrice: 200
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase(cashBalance: 500).execute(request, userID: "u1")
        }
    }

    @Test func givenBuyLimitOrder_whenInsufficientFunds_thenThrowsInsufficientFunds() async throws {
        // requerido = 150 * 10 = 1500, cash = 1000 → insuficiente
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .limit,
            quantity: 10,
            limitPrice: 150
        )

        await #expect(throws: IFError.self) {
            try await makeUseCase(cashBalance: 1000).execute(request, userID: "u1")
        }
    }

    // MARK: - Éxito

    @Test func givenBuyMarketOrder_whenSufficientFunds_thenReturnsOrder() async throws {
        // requerido = 100 * 5 = 500, cash = 10000 → ok
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .market,
            quantity: 5,
            estimatedMarketPrice: 100
        )

        let order = try await makeUseCase(cashBalance: 10_000).execute(request, userID: "u1")

        #expect(order.instrumentID == "AAPL")
        #expect(order.status == .filled)
    }

    @Test func givenSellOrder_whenExecuted_thenSkipsCashCheckAndSucceeds() async throws {
        // Las órdenes de venta nunca verifican el balance de cash
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .sell,
            type: .market,
            quantity: 10,
            estimatedMarketPrice: 200
        )

        let order = try await makeUseCase(cashBalance: .zero).execute(request, userID: "u1")

        #expect(order.side == .buy) // el mock devuelve un stub con side=.buy — solo se verifica que no lance
    }

    @Test func givenBuyMarketOrder_whenNoEstimatedPrice_thenSkipsCashCheckAndSucceeds() async throws {
        // Sin estimatedMarketPrice, se omite la verificación de cash
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .market,
            quantity: 100,
            estimatedMarketPrice: nil
        )

        let order = try await makeUseCase(cashBalance: .zero).execute(request, userID: "u1")

        #expect(order.instrumentID == "AAPL")
    }

    // MARK: - Orden límite válida exitosa

    @Test func givenLimitOrderWithPrice_whenSufficientFunds_thenReturnsOrder() async throws {
        let request = OrderRequest(
            instrumentID: "AAPL",
            side: .buy,
            type: .limit,
            quantity: 5,
            limitPrice: 100
        )

        let order = try await makeUseCase(cashBalance: 10_000).execute(request, userID: "u1")

        #expect(order.instrumentID == "AAPL")
    }
}
