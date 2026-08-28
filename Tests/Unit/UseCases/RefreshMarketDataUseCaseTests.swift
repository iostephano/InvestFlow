//
//  RefreshMarketDataUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("RefreshMarketDataUseCase")
struct RefreshMarketDataUseCaseTests {

    // MARK: - Cotización única

    @Test func givenValidID_whenExecutingForSingleInstrument_thenReturnsCorrectQuote() async throws {
        let expected = Quote.stub(id: "AAPL", price: 190, change: 5, changePercent: Decimal(string: "2.7")!)
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(quotes: [expected])
        )

        let result = try await useCase.execute(instrumentID: "AAPL")

        #expect(result.id == "AAPL")
        #expect(result.price == 190)
        #expect(result.change == 5)
    }

    @Test func givenUnknownID_whenExecutingForSingleInstrument_thenThrows() async {
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(quotes: [])
        )

        await #expect(throws: MockError.self) {
            try await useCase.execute(instrumentID: "UNKNOWN")
        }
    }

    // MARK: - Múltiples cotizaciones

    @Test func givenMultipleIDs_whenExecutingBatch_thenReturnsMatchingQuotes() async throws {
        let quotes = [
            Quote.stub(id: "AAPL", price: 190),
            Quote.stub(id: "TSLA", price: 220),
            Quote.stub(id: "SPY",  price: 500)
        ]
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(quotes: quotes)
        )

        let result = try await useCase.execute(instrumentIDs: ["AAPL", "TSLA"])

        #expect(result.count == 2)
        #expect(result.contains { $0.id == "AAPL" })
        #expect(result.contains { $0.id == "TSLA" })
        #expect(!result.contains { $0.id == "SPY" })
    }

    @Test func givenEmptyIDs_whenExecutingBatch_thenReturnsEmptyArray() async throws {
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(quotes: [Quote.stub()])
        )

        let result = try await useCase.execute(instrumentIDs: [])

        #expect(result.isEmpty)
    }

    // MARK: - Propagación de errores

    @Test func givenRepositoryThrows_whenExecutingSingle_thenErrorPropagates() async {
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(error: MockError.simulatedFailure)
        )

        await #expect(throws: MockError.self) {
            try await useCase.execute(instrumentID: "AAPL")
        }
    }

    @Test func givenRepositoryThrows_whenExecutingBatch_thenErrorPropagates() async {
        let useCase = RefreshMarketDataUseCase(
            repository: MockMarketRepository(error: MockError.simulatedFailure)
        )

        await #expect(throws: MockError.self) {
            try await useCase.execute(instrumentIDs: ["AAPL", "TSLA"])
        }
    }
}
