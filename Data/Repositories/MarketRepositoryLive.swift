//
//  MarketRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation
import FinCore

final class MarketRepositoryLive: MarketRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    nonisolated func fetchInstruments() async throws -> [Instrument] {
        do {
            let dtos: [InstrumentDTO] = try await apiClient.request(GetInstrumentsEndpoint())
            return InstrumentMapper.map(dtos)
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchInstrument(symbol: String) async throws -> Instrument? {
        do {
            let dto: InstrumentDTO = try await apiClient.request(GetInstrumentBySymbolEndpoint(symbol: symbol))
            return InstrumentMapper.map([dto]).first
        } catch {
            let mapped = mapToIFError(error)
            if case .notFound = mapped { return nil }
            throw mapped
        }
    }

    nonisolated func fetchQuote(for instrumentID: String) async throws -> Quote {
        do {
            let dto: QuoteDTO = try await apiClient.request(GetQuoteEndpoint(symbol: instrumentID))
            guard let quote = QuoteMapper.map(dto) else {
                throw IFError.notFound("cotización de \(instrumentID)")
            }
            return quote
        } catch {
            throw mapToIFError(error)
        }
    }

    nonisolated func fetchQuotes(for instrumentIDs: [String]) async throws -> [Quote] {
        do {
            let dtos: [QuoteDTO] = try await apiClient.request(GetQuotesBatchEndpoint(symbols: instrumentIDs))
            return QuoteMapper.map(dtos)
        } catch {
            throw mapToIFError(error)
        }
    }
}
