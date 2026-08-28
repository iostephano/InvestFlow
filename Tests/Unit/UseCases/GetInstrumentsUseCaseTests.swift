//
//  GetInstrumentsUseCaseTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore

@Suite("GetInstrumentsUseCase")
struct GetInstrumentsUseCaseTests {

    // MARK: - Filtro activo

    @Test func givenMixedActiveInactive_whenExecuted_thenOnlyActiveReturned() async throws {
        let active   = Instrument.stub(id: "AAPL", isActive: true)
        let inactive = Instrument.stub(id: "TSLA", isActive: false)
        let quote    = Quote.stub(id: "AAPL")

        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(instruments: [active, inactive], quotes: [quote])
        )

        let result = try await useCase.execute()

        #expect(result.count == 1)
        #expect(result[0].0.id == "AAPL")
    }

    @Test func givenAllActive_whenEachHasQuote_thenAllReturned() async throws {
        let instruments = [
            Instrument.stub(id: "AAPL"),
            Instrument.stub(id: "TSLA"),
            Instrument.stub(id: "SPY", type: .etf)
        ]
        let quotes = instruments.map { Quote.stub(id: $0.id) }

        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(instruments: instruments, quotes: quotes)
        )

        let result = try await useCase.execute()

        #expect(result.count == 3)
    }

    // MARK: - Sin instrumentos activos

    @Test func givenNoActiveInstruments_whenExecuted_thenReturnsEmptyArray() async throws {
        let instruments = [
            Instrument.stub(id: "AAPL", isActive: false),
            Instrument.stub(id: "TSLA", isActive: false)
        ]

        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(instruments: instruments, quotes: [])
        )

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    // MARK: - Cotización faltante excluye el instrumento

    @Test func givenActiveInstrumentWithoutQuote_whenExecuted_thenInstrumentExcluded() async throws {
        let withQuote    = Instrument.stub(id: "AAPL")
        let withoutQuote = Instrument.stub(id: "TSLA")
        let quote        = Quote.stub(id: "AAPL")

        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(instruments: [withQuote, withoutQuote], quotes: [quote])
        )

        let result = try await useCase.execute()

        #expect(result.count == 1)
        #expect(result[0].0.id == "AAPL")
    }

    // MARK: - Emparejamiento de cotizaciones

    @Test func givenActiveInstrument_whenExecuted_thenQuoteIsCorrectlyPaired() async throws {
        let instrument = Instrument.stub(id: "AAPL")
        let quote      = Quote.stub(id: "AAPL", price: 175, change: 3, changePercent: 1.75)

        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(instruments: [instrument], quotes: [quote])
        )

        let result = try await useCase.execute()
        let (returnedInstrument, returnedQuote) = try #require(result.first)

        #expect(returnedInstrument.id == "AAPL")
        #expect(returnedQuote.price == 175)
        #expect(returnedQuote.changePercent == Decimal(string: "1.75")!)
    }

    // MARK: - Propagación de errores

    @Test func givenRepositoryThrows_whenExecuted_thenErrorPropagates() async {
        let useCase = GetInstrumentsUseCase(
            repository: MockMarketRepository(error: MockError.simulatedFailure)
        )

        await #expect(throws: MockError.self) {
            try await useCase.execute()
        }
    }
}
