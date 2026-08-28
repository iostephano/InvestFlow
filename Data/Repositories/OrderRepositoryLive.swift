//
//  OrderRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation
import FinCore

final class OrderRepositoryLive: OrderRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    nonisolated func placeOrder(_ request: OrderRequest) async throws -> Order {
        let body = OrderRequestDTO(
            instrumentId: request.instrumentID,
            side:         request.side.rawValue,
            type:         request.type.rawValue,
            quantity:     request.quantity.description,
            limitPrice:   request.limitPrice?.description,
            stopPrice:    request.stopPrice?.description,
            timeInForce:  request.timeInForce.rawValue
        )
        do {
            let dto: OrderDTO = try await apiClient.request(try PlaceOrderEndpoint(body: body))
            guard let order = OrderMapper.map(dto) else {
                throw IFError.unknown("Respuesta de orden inválida del servidor")
            }
            return order
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func cancelOrder(id: String) async throws -> Order {
        do {
            let dto: OrderDTO = try await apiClient.request(CancelOrderEndpoint(orderID: id))
            guard let order = OrderMapper.map(dto) else {
                throw IFError.unknown("Respuesta de cancelación inválida del servidor")
            }
            return order
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchOrders(for userID: String, status: OrderStatus?) async throws -> [Order] {
        do {
            let endpoint = GetOrdersEndpoint(userID: userID, statusFilter: status?.rawValue)
            let dtos: [OrderDTO] = try await apiClient.request(endpoint)
            return OrderMapper.map(dtos)
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchOrder(id: String) async throws -> Order {
        do {
            let dto: OrderDTO = try await apiClient.request(GetOrderEndpoint(orderID: id))
            guard let order = OrderMapper.map(dto) else {
                throw IFError.notFound("orden \(id)")
            }
            return order
        } catch {
            throw mapToIFError(error)
        }
    }
}
