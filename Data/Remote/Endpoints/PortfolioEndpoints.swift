//
//  PortfolioEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - GET /users/{userID}/portfolio

struct GetPortfolioEndpoint: Endpoint {
    let userID: String
    var path:   String     { "/users/\(userID)/portfolio" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /users/{userID}/positions

struct GetPositionsEndpoint: Endpoint {
    let userID: String
    var path:   String     { "/users/\(userID)/positions" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /users/{userID}/transactions

struct GetTransactionsEndpoint: Endpoint {
    let userID: String
    let limit:  Int?
    var path:   String     { "/users/\(userID)/transactions" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        guard let limit else { return nil }
        return [URLQueryItem(name: "limit", value: String(limit))]
    }
}

// MARK: - GET /users/{userID}/profile

struct GetUserProfileEndpoint: Endpoint {
    let userID: String
    var path:   String     { "/users/\(userID)/profile" }
    var method: HTTPMethod { .get }
}
