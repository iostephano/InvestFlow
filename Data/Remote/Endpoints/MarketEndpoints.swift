//
//  MarketEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - GET /instruments

struct GetInstrumentsEndpoint: Endpoint {
    var path:   String     { "/instruments" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /quotes/{symbol}

struct GetQuoteEndpoint: Endpoint {
    let symbol: String
    var path:   String     { "/quotes/\(symbol)" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /instruments/{symbol}

struct GetInstrumentBySymbolEndpoint: Endpoint {
    let symbol: String
    var path:   String     { "/instruments/\(symbol)" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /quotes?symbols=A,B,C

struct GetQuotesBatchEndpoint: Endpoint {
    let symbols: [String]
    var path:   String { "/quotes" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        guard !symbols.isEmpty else { return nil }
        return [URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))]
    }
}
