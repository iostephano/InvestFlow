//
//  OrderRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public protocol OrderRepositoryProtocol: Sendable {
    func placeOrder(_ request: OrderRequest) async throws -> Order

    /// Cancela una orden activa. Solo válido para órdenes en estado .pending o .partiallyFilled.
    func cancelOrder(id: String) async throws -> Order

    /// - Parameter status: Filtra por estado. nil devuelve todas.
    func fetchOrders(for userID: String, status: OrderStatus?) async throws -> [Order]

    func fetchOrder(id: String) async throws -> Order
}
