//
//  TransferAmountViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("TransferAmountViewModel")
@MainActor
struct TransferAmountViewModelTests {

    // MARK: - Fixtures

    private let flatFeeMethod = TransferOption(
        id: "flat",
        method: .bankTransfer,
        name: "Transferencia bancaria",
        description: "Depósito vía banco",
        minAmount: 10,
        maxAmount: 5_000,
        estimatedTime: "1-2 días hábiles",
        fee: 3,
        feeIsPercentage: false
    )

    private let percentFeeMethod = TransferOption(
        id: "pct",
        method: .debitCard,
        name: "Tarjeta de débito",
        description: "Depósito vía tarjeta",
        minAmount: 10,
        maxAmount: 2_000,
        estimatedTime: "Inmediato",
        fee: 0.015,
        feeIsPercentage: true
    )

    private let country = SupportedCountry(
        id: "PE",
        name: "Perú",
        flagEmoji: "🇵🇪",
        dialCode: "+51",
        isSupported: true
    )

    private func makeViewModel(method: TransferOption) -> TransferAmountViewModel {
        TransferAmountViewModel(
            country: country,
            method: method,
            flowType: .deposit,
            userID: "u1"
        )
    }

    // MARK: - feeAmount (fijo)

    @Test func feeAmount_flatFee_returnsFixedAmount() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "100"
        #expect(vm.feeAmount == 3)
    }

    // MARK: - feeAmount (porcentaje)

    @Test func feeAmount_percentageFee_returnsCalculatedAmount() {
        let vm = makeViewModel(method: percentFeeMethod)
        vm.amountText = "200"
        #expect(vm.feeAmount == 3)    // 200 * 0.015 = 3.00
    }

    @Test func feeAmount_emptyAmount_returnsZero() {
        let vm = makeViewModel(method: flatFeeMethod)
        #expect(vm.feeAmount == .zero)
    }

    // MARK: - netAmount

    @Test func netAmount_flatFee_returnsAmountMinusFee() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "100"
        #expect(vm.netAmount == 97)
    }

    @Test func netAmount_emptyAmount_returnsZero() {
        let vm = makeViewModel(method: flatFeeMethod)
        #expect(vm.netAmount == .zero)
    }

    // MARK: - validationError

    @Test func validationError_emptyText_isNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        #expect(vm.validationError == nil)
    }

    @Test func validationError_invalidText_isNotNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "abc"
        #expect(vm.validationError != nil)
    }

    @Test func validationError_belowMinimum_isNotNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "5"   // minAmount = 10
        #expect(vm.validationError != nil)
    }

    @Test func validationError_aboveMaximum_isNotNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "6000"  // maxAmount = 5000
        #expect(vm.validationError != nil)
    }

    @Test func validationError_validAmount_isNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "500"
        #expect(vm.validationError == nil)
    }

    // MARK: - canContinue

    @Test func canContinue_emptyText_isFalse() {
        let vm = makeViewModel(method: flatFeeMethod)
        #expect(!vm.canContinue)
    }

    @Test func canContinue_validAmount_isTrue() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "100"
        #expect(vm.canContinue)
    }

    @Test func canContinue_invalidAmount_isFalse() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "abc"
        #expect(!vm.canContinue)
    }

    // MARK: - buildRequest

    @Test func buildRequest_validAmount_returnsRequest() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "100"
        let request = vm.buildRequest()
        #expect(request != nil)
        #expect(request?.amount == 100)
        #expect(request?.userID == "u1")
    }

    @Test func buildRequest_invalidAmount_returnsNil() {
        let vm = makeViewModel(method: flatFeeMethod)
        vm.amountText = "abc"
        #expect(vm.buildRequest() == nil)
    }
}
