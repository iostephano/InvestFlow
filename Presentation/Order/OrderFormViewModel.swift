//
//  OrderFormViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class OrderFormViewModel {

    enum SubmitState {
        case idle
        case placing
        case success(Order)
        case failure(Error)

        var isPlacing: Bool {
            if case .placing = self { return true }
            return false
        }

        var succeededOrder: Order? {
            if case .success(let order) = self { return order }
            return nil
        }
    }

    private(set) var loadState: LoadState<(Instrument, Quote)> = .idle

    var quantityText: String = ""
    var selectedSide: OrderSide = .buy
    var selectedOrderType: OrderType = .market
    var limitPriceText: String = ""
    var stopPriceText: String = ""
    var submitState: SubmitState = .idle

    let instrumentID: String
    private let userID: String
    private let getAssetDetailUseCase: GetAssetDetailUseCase
    private let placeOrderUseCase: PlaceOrderUseCase

    init(
        instrumentID: String,
        userID: String,
        getAssetDetailUseCase: GetAssetDetailUseCase,
        placeOrderUseCase: PlaceOrderUseCase,
        initialSide: OrderSide = .buy
    ) {
        self.instrumentID = instrumentID
        self.userID = userID
        self.getAssetDetailUseCase = getAssetDetailUseCase
        self.placeOrderUseCase = placeOrderUseCase
        self.selectedSide = initialSide
    }

    // MARK: - Derivadas

    var instrument: Instrument? {
        guard case .loaded(let pair) = loadState else { return nil }
        return pair.0
    }

    var quote: Quote? {
        guard case .loaded(let pair) = loadState else { return nil }
        return pair.1
    }

    var quantityDecimal: Decimal? {
        guard !quantityText.isEmpty else { return nil }
        return Decimal(string: quantityText)
    }

    var limitPriceDecimal: Decimal? {
        guard !limitPriceText.isEmpty else { return nil }
        return Decimal(string: limitPriceText)
    }

    var stopPriceDecimal: Decimal? {
        guard !stopPriceText.isEmpty else { return nil }
        return Decimal(string: stopPriceText)
    }

    var needsLimitPrice: Bool {
        selectedOrderType == .limit || selectedOrderType == .stopLimit
    }

    var needsStopPrice: Bool {
        selectedOrderType == .stopLoss || selectedOrderType == .stopLimit
    }

    var estimatedTotal: Decimal? {
        guard let qty = quantityDecimal, qty > .zero else { return nil }
        let price: Decimal
        if needsLimitPrice, let p = limitPriceDecimal, p > .zero {
            price = p
        } else if needsStopPrice, let p = stopPriceDecimal, p > .zero {
            price = p
        } else {
            price = quote?.price ?? .zero
        }
        guard price > .zero else { return nil }
        return price * qty
    }

    var canSubmit: Bool {
        guard let qty = quantityDecimal, qty > .zero else { return false }
        if needsLimitPrice {
            guard let p = limitPriceDecimal, p > .zero else { return false }
        }
        if needsStopPrice {
            guard let p = stopPriceDecimal, p > .zero else { return false }
        }
        return !submitState.isPlacing
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading
        do {
            let pair = try await getAssetDetailUseCase.execute(symbol: instrumentID)
            loadState = .loaded(pair)
        } catch {
            loadState = .failed(IFError.from(error))
        }
    }

    func submit() async {
        guard canSubmit, let qty = quantityDecimal else { return }

        submitState = .placing

        let request = OrderRequest(
            instrumentID:         instrumentID,
            side:                 selectedSide,
            type:                 selectedOrderType,
            quantity:             qty,
            limitPrice:           needsLimitPrice ? limitPriceDecimal : nil,
            stopPrice:            needsStopPrice  ? stopPriceDecimal  : nil,
            timeInForce:          .day,
            estimatedMarketPrice: selectedOrderType == .market ? quote?.price : nil
        )

        do {
            let order = try await placeOrderUseCase.execute(request, userID: userID)
            submitState = .success(order)
        } catch {
            submitState = .failure(error)
        }
    }

    func resetForm() {
        quantityText = ""
        limitPriceText = ""
        stopPriceText = ""
        submitState = .idle
    }
}
