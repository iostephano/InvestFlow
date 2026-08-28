//
//  MarketRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

public final class MarketRepository: MarketRepositoryProtocol, Sendable {
    
    public init() {}
    
    public func fetchInstruments() async throws -> [Instrument] {
        try await Task.sleep(for: .milliseconds(150))
        
        return Self.mockInstruments
    }
    
    public func fetchInstrument(symbol: String) async throws -> Instrument? {
        try await Task.sleep(for: .milliseconds(80))
        return Self.mockInstruments.first { $0.id == symbol }
    }

    public func fetchQuote(for instrumentID: String) async throws -> Quote {
        try await Task.sleep(for: .milliseconds(80))
        return Self.mockQuote(for: instrumentID)
    }
    
    public func fetchQuotes(for instrumentIDs: [String]) async throws -> [Quote] {
        try await withThrowingTaskGroup(of: Quote.self) { group in
            for id in instrumentIDs {
                group.addTask {
                    try await self.fetchQuote(for: id)
                }
            }
            
            var results: [Quote] = []
            for try await quote in group {
                results.append(quote)
            }
            return results
        }
    }
}

// MARK: - Mapeo NetworkError → IFError
// Se usa al conectar el APIClient real. Llamar a mapNetworkError dentro de los bloques catch.

private extension MarketRepository {
    static func mapNetworkError(_ error: NetworkError) -> IFError {
        switch error {
        case .unauthorized, .sessionExpired:
            return .unauthorized
        case .requestFailed(let code) where code == 404:
            return .notFound("instrumento")
        case .requestFailed(let code):
            return .serverError(statusCode: code)
        case .serverError(let code, _):
            return .serverError(statusCode: code)
        case .invalidURL, .decodingFailed, .invalidResponse, .cancelled:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Datos mock

private extension MarketRepository {
    
    static let mockInstruments: [Instrument] = [
        Instrument(
            id: "AAPL",
            name: "Apple Inc.",
            type: .stock,
            currency: .usd,
            logoURL: URL(string: "https://logo.clearbit.com/apple.com"),
            exchange: "NASDAQ"
        ),
        Instrument(
            id: "TSLA",
            name: "Tesla Inc.",
            type: .stock,
            currency: .usd,
            logoURL: URL(string: "https://logo.clearbit.com/tesla.com"),
            exchange: "NASDAQ"
        ),
        Instrument(
            id: "SPY",
            name: "SPDR S&P 500 ETF",
            type: .etf,
            currency: .usd,
            logoURL: URL(string: "https://logo.clearbit.com/ssga.com"),
            exchange: "NYSE"
        ),
        Instrument(
            id: "BTC",
            name: "Bitcoin",
            type: .crypto,
            currency: .usd,
            exchange: "CRYPTO"
        ),
        Instrument(
            id: "ETH",
            name: "Ethereum",
            type: .crypto,
            currency: .usd,
            exchange: "CRYPTO"
        ),
        Instrument(
            id: "QQQ",
            name: "Invesco QQQ Trust",
            type: .etf,
            currency: .usd,
            exchange: "NASDAQ"
        )
    ]
    
    static func mockQuote(for id: String) -> Quote {
        let mockPrices: [String: (price: Decimal, change: Decimal)] = [
            "AAPL": (Decimal(string: "189.45")!, Decimal(string: "2.30")!),
            "TSLA": (Decimal(string: "248.12")!, Decimal(string: "-4.55")!),
            "SPY":  (Decimal(string: "524.80")!, Decimal(string: "1.20")!),
            "BTC":  (Decimal(string: "67420.00")!, Decimal(string: "1250.00")!),
            "ETH":  (Decimal(string: "3580.50")!, Decimal(string: "-89.30")!),
            "QQQ":  (Decimal(string: "449.20")!, Decimal(string: "3.10")!)
        ]
        
        let data = mockPrices[id] ?? (Decimal(string: "100.00")!, Decimal(string: "0.00")!)
        let previousClose = data.price - data.change
        let changePercent = previousClose > .zero
            ? (data.change / previousClose) * 100
            : .zero
        
        return Quote(
            id: id,
            price: data.price,
            change: data.change,
            changePercent: changePercent,
            volume: Int64.random(in: 1_000_000...50_000_000)
        )
    }
}
