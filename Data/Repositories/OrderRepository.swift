//
//  OrderRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

public enum OrderRepositoryError: Error, Sendable {
    case orderNotFound(id: String)
    case orderNotCancellable(status: OrderStatus)
    case insufficientFunds
    case instrumentNotTradable
}

public final class OrderRepository: OrderRepositoryProtocol, Sendable {

    private let broker: MockBrokerStore

    public init(broker: MockBrokerStore = .shared) {
        self.broker = broker
    }

    // MARK: - OrderRepositoryProtocol

    public func placeOrder(_ request: OrderRequest) async throws -> Order {
        try await Task.sleep(for: .milliseconds(200))
        // El broker mock es la única fuente de verdad: ejecuta la orden, mueve el cash,
        // actualiza la posición y agrega los registros de orden + transacción que
        // PortfolioRepository vuelve a leer.
        return try await broker.applyOrder(request, fillPrice: fillPrice(for: request))
    }

    public func cancelOrder(id: String) async throws -> Order {
        try await Task.sleep(for: .milliseconds(120))

        guard let order = await broker.currentOrders().first(where: { $0.id == id }) else {
            throw OrderRepositoryError.orderNotFound(id: id)
        }
        guard order.isActive else {
            throw OrderRepositoryError.orderNotCancellable(status: order.status)
        }
        return order.withStatus(.cancelled)
    }

    public func fetchOrders(for userID: String, status: OrderStatus?) async throws -> [Order] {
        try await Task.sleep(for: .milliseconds(110))
        let orders = await broker.currentOrders()
        guard let status else { return orders }
        return orders.filter { $0.status == status }
    }

    public func fetchOrder(id: String) async throws -> Order {
        try await Task.sleep(for: .milliseconds(70))
        guard let order = await broker.currentOrders().first(where: { $0.id == id }) else {
            throw OrderRepositoryError.orderNotFound(id: id)
        }
        return order
    }

    // MARK: - Datos de mercado mock

    /// Precio al que ejecuta el broker mock. Las órdenes market usan la cotización mock viva;
    /// las órdenes límite / stop registran su precio de disparo (en la demo nunca se ejecutan).
    private func fillPrice(for request: OrderRequest) -> Decimal {
        switch request.type {
        case .market:
            return Self.mockFillPrice(for: request.instrumentID)
        case .limit, .stopLimit:
            return request.limitPrice ?? Self.mockFillPrice(for: request.instrumentID)
        case .stopLoss:
            return request.stopPrice ?? Self.mockFillPrice(for: request.instrumentID)
        }
    }

    static func mockFillPrice(for instrumentID: String) -> Decimal {
        let prices: [String: Decimal] = [
            "AAPL": Decimal(string: "189.45")!,
            "TSLA": Decimal(string: "248.12")!,
            "SPY":  Decimal(string: "524.80")!,
            "BTC":  Decimal(string: "67420.00")!,
            "ETH":  Decimal(string: "3580.50")!,
            "QQQ":  Decimal(string: "449.20")!
        ]
        return prices[instrumentID] ?? Decimal(string: "100.00")!
    }
}
