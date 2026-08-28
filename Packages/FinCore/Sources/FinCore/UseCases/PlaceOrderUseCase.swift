//
//  PlaceOrderUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Valida y envía una orden de compra o venta.
public struct PlaceOrderUseCase: Sendable {

    private let orderRepository: any OrderRepositoryProtocol
    private let portfolioRepository: any PortfolioRepositoryProtocol

    public init(
        orderRepository: any OrderRepositoryProtocol,
        portfolioRepository: any PortfolioRepositoryProtocol
    ) {
        self.orderRepository = orderRepository
        self.portfolioRepository = portfolioRepository
    }

    public func execute(_ request: OrderRequest, userID: String) async throws -> Order {
        guard request.quantity > .zero else {
            throw IFError.validationFailed("La cantidad debe ser mayor a cero.")
        }

        switch request.type {
        case .limit:
            guard let lp = request.limitPrice, lp > .zero else {
                throw IFError.validationFailed("Ingresa un precio límite válido.")
            }
        case .stopLoss:
            guard let sp = request.stopPrice, sp > .zero else {
                throw IFError.validationFailed("Ingresa un precio stop válido.")
            }
        case .stopLimit:
            guard (request.limitPrice ?? .zero) > .zero else {
                throw IFError.validationFailed("Ingresa un precio límite válido.")
            }
            guard (request.stopPrice ?? .zero) > .zero else {
                throw IFError.validationFailed("Ingresa un precio stop válido.")
            }
        case .market:
            break
        }

        if request.side == .buy {
            let referencePrice: Decimal? = switch request.type {
            case .market:    request.estimatedMarketPrice
            case .limit:     request.limitPrice
            case .stopLoss:  request.stopPrice
            case .stopLimit: request.limitPrice
            }

            if let price = referencePrice, price > .zero {
                let cashBalance = try await portfolioRepository.fetchCashBalance(for: userID)
                let required = price * request.quantity
                guard cashBalance >= required else {
                    throw IFError.validationFailed("Saldo insuficiente para esta operación.")
                }
            }
        }

        let order = try await orderRepository.placeOrder(request)
        await portfolioRepository.invalidateCache(for: userID)
        return order
    }
}
