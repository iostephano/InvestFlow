//
//  MockOrderRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

struct MockOrderRepository: OrderRepositoryProtocol {

    let orderToReturn: Order
    let ordersToReturn: [Order]
    let error: Error?

    init(
        orderToReturn: Order = .stub(),
        ordersToReturn: [Order] = [],
        error: Error? = nil
    ) {
        self.orderToReturn = orderToReturn
        self.ordersToReturn = ordersToReturn
        self.error = error
    }

    func placeOrder(_ request: OrderRequest) async throws -> Order {
        if let error { throw error }
        return orderToReturn
    }

    func cancelOrder(id: String) async throws -> Order {
        if let error { throw error }
        return orderToReturn.withStatus(.cancelled)
    }

    func fetchOrders(for userID: String, status: OrderStatus?) async throws -> [Order] {
        if let error { throw error }
        guard let status else { return ordersToReturn }
        return ordersToReturn.filter { $0.status == status }
    }

    func fetchOrder(id: String) async throws -> Order {
        if let error { throw error }
        guard let order = ordersToReturn.first(where: { $0.id == id }) else {
            throw MockError.notFound
        }
        return order
    }
}
