//
//  OrderEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - POST /orders

struct PlaceOrderEndpoint: Endpoint {
    var path:    String     { "/orders" }
    var method:  HTTPMethod { .post }
    let bodyData: Data?

    init(body: OrderRequestDTO) throws {
        bodyData = try JSONEncoder.investFlow().encode(body)
    }
}

// MARK: - GET /orders/{orderID}

struct GetOrderEndpoint: Endpoint {
    let orderID: String
    var path:   String     { "/orders/\(orderID)" }
    var method: HTTPMethod { .get }
}

// MARK: - DELETE /orders/{orderID}

struct CancelOrderEndpoint: Endpoint {
    let orderID: String
    var path:   String     { "/orders/\(orderID)" }
    var method: HTTPMethod { .delete }
}

// MARK: - GET /orders?userId={id}&status={status}

struct GetOrdersEndpoint: Endpoint {
    let userID:       String
    let statusFilter: String?
    var path:   String     { "/orders" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        var items = [URLQueryItem(name: "userId", value: userID)]
        if let s = statusFilter {
            items.append(URLQueryItem(name: "status", value: s))
        }
        return items
    }
}
