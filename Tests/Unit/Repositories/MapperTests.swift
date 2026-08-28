//
//  MapperTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

// MARK: - InstrumentMapper

@Suite("InstrumentMapper")
struct InstrumentMapperTests {

    private func validDTO(
        id: String = "AAPL",
        name: String = "Apple Inc.",
        type: String = "STOCK",
        currency: String = "USD",
        exchange: String = "NASDAQ",
        isActive: Bool = true,
        logoUrl: String? = nil
    ) -> InstrumentDTO {
        InstrumentDTO(
            id: id,
            name: name,
            type: type,
            currency: currency,
            logoUrl: logoUrl,
            exchange: exchange,
            isActive: isActive
        )
    }

    @Test func validDTO_mapsAllFields() {
        let dto = validDTO(id: "AAPL", name: "Apple Inc.", exchange: "NASDAQ", isActive: true)

        let instrument = InstrumentMapper.map(dto)

        #expect(instrument != nil)
        #expect(instrument?.id == "AAPL")
        #expect(instrument?.name == "Apple Inc.")
        #expect(instrument?.type == .stock)
        #expect(instrument?.currency == .usd)
        #expect(instrument?.exchange == "NASDAQ")
        #expect(instrument?.isActive == true)
    }

    @Test func validDTO_withLogoURL_mapsURL() {
        let dto = validDTO(logoUrl: "https://example.com/logo.png")

        let instrument = InstrumentMapper.map(dto)

        #expect(instrument?.logoURL == URL(string: "https://example.com/logo.png"))
    }

    @Test func unknownType_returnsNil() {
        let dto = validDTO(type: "UNKNOWN_ASSET")

        let instrument = InstrumentMapper.map(dto)

        #expect(instrument == nil)
    }

    @Test func unknownCurrency_returnsNil() {
        let dto = validDTO(currency: "XYZ")

        let instrument = InstrumentMapper.map(dto)

        #expect(instrument == nil)
    }

    @Test func inactiveDTO_mapsWithIsActiveFalse() {
        let dto = validDTO(isActive: false)

        let instrument = InstrumentMapper.map(dto)

        #expect(instrument?.isActive == false)
    }

    @Test func mapArray_filtersOutInvalidDTOs() {
        let dtos = [
            validDTO(id: "AAPL"),
            validDTO(id: "BTC", type: "CRYPTO"),
            validDTO(id: "BAD", type: "UNKNOWN"),
        ]

        let instruments = InstrumentMapper.map(dtos)

        #expect(instruments.count == 2)
    }

    // GetInstrumentsUseCase filtra los instrumentos inactivos
    @Test func getInstrumentsUseCase_excludesInactiveInstruments() async throws {
        let active   = Instrument.stub(id: "AAPL", isActive: true)
        let inactive = Instrument.stub(id: "OLD", isActive: false)
        let repo = MockMarketRepository(
            instruments: [active, inactive],
            quotes: [.stub(id: "AAPL")]
        )

        let result = try await GetInstrumentsUseCase(repository: repo).execute()

        #expect(result.count == 1)
        #expect(result.first?.0.id == "AAPL")
    }
}

// MARK: - QuoteMapper

@Suite("QuoteMapper")
struct QuoteMapperTests {

    private func dto(
        id: String = "AAPL",
        price: String = "123.45",
        change: String = "1.23",
        changePercent: String = "1.01",
        volume: Int64 = 1_000_000
    ) -> QuoteDTO {
        QuoteDTO(
            id: id,
            price: price,
            change: change,
            changePercent: changePercent,
            volume: volume,
            timestamp: Date()
        )
    }

    @Test func validStrings_mapToExactDecimals() {
        let quote = QuoteMapper.map(dto(price: "123.45", change: "1.23", changePercent: "1.01"))

        #expect(quote != nil)
        #expect(quote?.price == Decimal(string: "123.45"))
        #expect(quote?.change == Decimal(string: "1.23"))
        #expect(quote?.changePercent == Decimal(string: "1.01"))
    }

    @Test func highPrecisionPrice_preservesPrecision() {
        let quote = QuoteMapper.map(dto(price: "189.456789"))

        #expect(quote?.price == Decimal(string: "189.456789"))
    }

    @Test func emptyPriceString_returnsNil() {
        let quote = QuoteMapper.map(dto(price: ""))

        #expect(quote == nil)
    }

    @Test func invalidPriceString_returnsNil() {
        let quote = QuoteMapper.map(dto(price: "not-a-number"))

        #expect(quote == nil)
    }

    @Test func emptyChangePercent_returnsNil() {
        let quote = QuoteMapper.map(dto(changePercent: ""))

        #expect(quote == nil)
    }

    @Test func volume_mapsCorrectly() {
        let quote = QuoteMapper.map(dto(volume: 5_432_100))

        #expect(quote?.volume == 5_432_100)
    }
}

// MARK: - PositionMapper

@Suite("PositionMapper")
struct PositionMapperTests {

    private func dto(
        instrumentId: String = "AAPL",
        instrumentType: String? = "STOCK",
        quantity: String = "10",
        averageCostBasis: String = "100.00",
        currentPrice: String = "150.00"
    ) -> PositionDTO {
        PositionDTO(
            instrumentId: instrumentId,
            instrumentType: instrumentType,
            quantity: quantity,
            averageCostBasis: averageCostBasis,
            currentPrice: currentPrice
        )
    }

    @Test func validDTO_mapsAllFields() {
        let position = PositionMapper.map(dto())

        #expect(position?.instrumentID == "AAPL")
        #expect(position?.quantity == 10)
        #expect(position?.averageCostBasis == 100)
        #expect(position?.currentPrice == 150)
    }

    @Test func computedMarketValue_isCorrect() {
        // qty=10, precio=150 → marketValue=1500
        let position = PositionMapper.map(dto(quantity: "10", currentPrice: "150.00"))

        #expect(position?.marketValue == 1500)
    }

    @Test func computedUnrealizedPL_isCorrect() {
        // qty=10, costo=100, precio=150 → PL = (150-100)*10 = 500
        let position = PositionMapper.map(dto(quantity: "10", averageCostBasis: "100.00", currentPrice: "150.00"))

        #expect(position?.unrealizedPL == 500)
    }

    @Test func computedUnrealizedPLPercent_isCorrect() {
        // PL=500, costo=1000 → 50%
        let position = PositionMapper.map(dto(quantity: "10", averageCostBasis: "100.00", currentPrice: "150.00"))

        #expect(position?.unrealizedPLPercent == 50)
    }

    @Test func nilInstrumentType_defaultsToStock() {
        let position = PositionMapper.map(dto(instrumentType: nil))

        #expect(position?.instrumentType == .stock)
    }

    @Test func invalidQuantity_returnsNil() {
        let position = PositionMapper.map(dto(quantity: "bad"))

        #expect(position == nil)
    }

    @Test func invalidCurrentPrice_returnsNil() {
        let position = PositionMapper.map(dto(currentPrice: ""))

        #expect(position == nil)
    }
}

// MARK: - OrderMapper

@Suite("OrderMapper")
struct OrderMapperTests {

    private func dto(
        id: String = "ord-1",
        side: String = "BUY",
        type: String = "MARKET",
        status: String = "FILLED",
        quantity: String = "5",
        filledQuantity: String = "5",
        timeInForce: String = "DAY",
        limitPrice: String? = nil,
        stopPrice: String? = nil,
        averageFillPrice: String? = "150.00"
    ) -> OrderDTO {
        OrderDTO(
            id: id,
            instrumentId: "AAPL",
            side: side,
            type: type,
            quantity: quantity,
            limitPrice: limitPrice,
            stopPrice: stopPrice,
            status: status,
            timeInForce: timeInForce,
            filledQuantity: filledQuantity,
            averageFillPrice: averageFillPrice,
            placedAt: Date(),
            updatedAt: Date()
        )
    }

    @Test func allStatusValues_mapCorrectly() {
        let cases: [(String, OrderStatus)] = [
            ("PENDING",          .pending),
            ("FILLED",           .filled),
            ("PARTIALLY_FILLED", .partiallyFilled),
            ("CANCELLED",        .cancelled),
            ("REJECTED",         .rejected),
            ("EXPIRED",          .expired),
        ]
        for (raw, expected) in cases {
            let order = OrderMapper.map(dto(status: raw))
            #expect(order?.status == expected, "Status \(raw) should map to \(expected)")
        }
    }

    @Test func allSideValues_mapCorrectly() {
        #expect(OrderMapper.map(dto(side: "BUY"))?.side == .buy)
        #expect(OrderMapper.map(dto(side: "SELL"))?.side == .sell)
    }

    @Test func allOrderTypes_mapCorrectly() {
        let cases: [(String, OrderType)] = [
            ("MARKET",     .market),
            ("LIMIT",      .limit),
            ("STOP_LOSS",  .stopLoss),
            ("STOP_LIMIT", .stopLimit),
        ]
        for (raw, expected) in cases {
            let order = OrderMapper.map(dto(type: raw))
            #expect(order?.type == expected, "Type \(raw) should map to \(expected)")
        }
    }

    @Test func unknownStatus_returnsNil() {
        let order = OrderMapper.map(dto(status: "UNKNOWN_STATUS"))

        #expect(order == nil)
    }

    @Test func limitPrice_mapsToDecimal() {
        let order = OrderMapper.map(dto(type: "LIMIT", limitPrice: "175.50"))

        #expect(order?.limitPrice == Decimal(string: "175.50"))
    }

    @Test func nilOptionalFields_mapToNil() {
        let order = OrderMapper.map(dto(limitPrice: nil, stopPrice: nil, averageFillPrice: nil))

        #expect(order?.limitPrice == nil)
        #expect(order?.stopPrice == nil)
        #expect(order?.averageFillPrice == nil)
    }
}

// MARK: - TransactionMapper

@Suite("TransactionMapper")
struct TransactionMapperTests {

    private func dto(
        id: String = "tx-1",
        type: String = "DEPOSIT",
        price: String = "500.00",
        fee: String = "0.00",
        currency: String = "USD",
        quantity: String? = nil
    ) -> TransactionDTO {
        TransactionDTO(
            id: id,
            orderId: nil,
            instrumentId: nil,
            type: type,
            quantity: quantity,
            price: price,
            fee: fee,
            currency: currency,
            executedAt: Date()
        )
    }

    @Test func allTransactionTypes_mapCorrectly() {
        let cases: [(String, TransactionType)] = [
            ("BUY",        .buy),
            ("SELL",       .sell),
            ("DIVIDEND",   .dividend),
            ("FEE",        .fee),
            ("DEPOSIT",    .deposit),
            ("WITHDRAWAL", .withdrawal),
        ]
        for (raw, expected) in cases {
            let tx = TransactionMapper.map(dto(type: raw))
            #expect(tx?.type == expected, "Type \(raw) should map to \(expected)")
        }
    }

    @Test func unknownType_returnsNil() {
        let tx = TransactionMapper.map(dto(type: "UNKNOWN"))

        #expect(tx == nil)
    }

    @Test func price_mapsToExactDecimal() {
        let tx = TransactionMapper.map(dto(price: "1234.56"))

        #expect(tx?.price == Decimal(string: "1234.56"))
    }

    @Test func feeZero_mapsCorrectly() {
        let tx = TransactionMapper.map(dto(fee: "0.00"))

        #expect(tx?.fee == .zero)
    }

    @Test func quantity_whenPresent_mapsToDecimal() {
        let tx = TransactionMapper.map(dto(type: "BUY", quantity: "3.5"))

        #expect(tx?.quantity == Decimal(string: "3.5"))
    }

    @Test func quantity_whenAbsent_isNil() {
        let tx = TransactionMapper.map(dto(quantity: nil))

        #expect(tx?.quantity == nil)
    }

    @Test func invalidCurrency_returnsNil() {
        let tx = TransactionMapper.map(dto(currency: "XYZ"))

        #expect(tx == nil)
    }
}
