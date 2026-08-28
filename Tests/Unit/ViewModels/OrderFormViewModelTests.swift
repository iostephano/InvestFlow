//
//  OrderFormViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("OrderFormViewModel")
@MainActor
struct OrderFormViewModelTests {

    func makeViewModel(
        instrumentID: String = "AAPL",
        cashBalance: Decimal = 10_000,
        marketError: Error? = nil,
        orderError: Error? = nil
    ) -> OrderFormViewModel {
        let instrument = Instrument.stub(id: instrumentID)
        let quote      = Quote.stub(id: instrumentID, price: 150)
        let marketRepo = MockMarketRepository(
            instruments: [instrument],
            quotes: [quote],
            error: marketError
        )
        let portfolioRepo = MockPortfolioRepository(cashBalance: cashBalance)
        return OrderFormViewModel(
            instrumentID: instrumentID,
            userID: "u1",
            getAssetDetailUseCase: GetAssetDetailUseCase(repository: marketRepo),
            placeOrderUseCase: PlaceOrderUseCase(
                orderRepository: MockOrderRepository(error: orderError),
                portfolioRepository: portfolioRepo
            )
        )
    }

    // MARK: - Validación de canSubmit

    @Test func canSubmit_whenQuantityIsZero_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "0"
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenQuantityIsNegative_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "-5"
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenQuantityEmpty_isFalse() {
        let vm = makeViewModel()
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenLimitOrderWithoutLimitPrice_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .limit
        vm.limitPriceText = ""
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenLimitOrderWithZeroLimitPrice_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .limit
        vm.limitPriceText = "0"
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenMarketOrderWithValidQuantity_isTrue() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .market
        #expect(vm.canSubmit)
    }

    @Test func canSubmit_whenLimitOrderWithValidPriceAndQuantity_isTrue() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .limit
        vm.limitPriceText = "100"
        #expect(vm.canSubmit)
    }

    // MARK: - estimatedTotal

    @Test func estimatedTotal_whenNoQuantity_isNil() {
        let vm = makeViewModel()
        #expect(vm.estimatedTotal == nil)
    }

    @Test func estimatedTotal_calculatesCorrectly_usingQuotePrice() async throws {
        let vm = makeViewModel()
        await vm.load()

        vm.quantityText = "3"
        vm.selectedOrderType = .market

        // quote.price = 150, qty = 3 → 450
        #expect(vm.estimatedTotal == 450)
    }

    @Test func estimatedTotal_limitOrder_usesLimitPrice() {
        let vm = makeViewModel()
        vm.quantityText = "4"
        vm.selectedOrderType = .limit
        vm.limitPriceText = "200"

        // 200 * 4 = 800
        #expect(vm.estimatedTotal == 800)
    }

    // MARK: - Flujo de envío

    @Test func submit_success_stateTransitionsThroughPlacingToSuccess() async throws {
        let vm = makeViewModel(cashBalance: 10_000)
        await vm.load()
        vm.quantityText = "1"
        vm.selectedOrderType = .market

        await vm.submit()

        if case .success = vm.submitState { } else {
            Issue.record("Expected .success, got \(vm.submitState)")
        }
    }

    @Test func submit_insufficientFunds_stateIsFailure() async throws {
        // qty=10, price=150 → hacen falta $1500, cash=$100 → PlaceOrderUseCase lanza
        let vm = makeViewModel(cashBalance: 100)
        await vm.load()
        vm.quantityText = "10"
        vm.selectedOrderType = .market

        await vm.submit()

        if case .failure = vm.submitState { } else {
            Issue.record("Expected .failure, got \(vm.submitState)")
        }
    }

    @Test func submit_orderError_stateIsFailure() async throws {
        let vm = makeViewModel(
            cashBalance: 10_000,
            orderError: MockError.simulatedFailure
        )
        await vm.load()
        vm.quantityText = "1"
        vm.selectedOrderType = .market

        await vm.submit()

        if case .failure = vm.submitState { } else {
            Issue.record("Expected .failure, got \(vm.submitState)")
        }
    }

    // MARK: - Validación de precio stop

    @Test func canSubmit_whenStopLossWithoutStopPrice_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .stopLoss
        vm.stopPriceText = ""
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenStopLossWithStopPrice_isTrue() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .stopLoss
        vm.stopPriceText = "140"
        #expect(vm.canSubmit)
    }

    @Test func canSubmit_whenStopLimitWithLimitButNoStop_isFalse() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .stopLimit
        vm.limitPriceText = "145"
        vm.stopPriceText = ""
        #expect(!vm.canSubmit)
    }

    @Test func canSubmit_whenStopLimitWithBothPrices_isTrue() {
        let vm = makeViewModel()
        vm.quantityText = "5"
        vm.selectedOrderType = .stopLimit
        vm.limitPriceText = "145"
        vm.stopPriceText = "140"
        #expect(vm.canSubmit)
    }

    @Test func estimatedTotal_stopLossOrder_usesStopPrice() {
        let vm = makeViewModel()
        vm.quantityText = "3"
        vm.selectedOrderType = .stopLoss
        vm.stopPriceText = "130"

        // 130 * 3 = 390
        #expect(vm.estimatedTotal == 390)
    }

    @Test func resetForm_clearsStopPriceText() async throws {
        let vm = makeViewModel(cashBalance: 10_000)
        await vm.load()
        vm.quantityText = "5"
        vm.selectedOrderType = .stopLoss
        vm.stopPriceText = "140"
        await vm.submit()

        vm.resetForm()

        #expect(vm.stopPriceText.isEmpty)
    }

    // MARK: - Reinicio

    @Test func resetForm_clearsQuantityAndState() async throws {
        let vm = makeViewModel(cashBalance: 10_000)
        await vm.load()
        vm.quantityText = "5"
        await vm.submit()

        vm.resetForm()

        #expect(vm.quantityText.isEmpty)
        if case .idle = vm.submitState { } else {
            Issue.record("Expected .idle after reset, got \(vm.submitState)")
        }
    }
}
