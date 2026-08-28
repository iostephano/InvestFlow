//
//  TestFixtures.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

// MARK: - Instrument

extension Instrument {
    nonisolated static func stub(
        id: String = "AAPL",
        name: String = "Apple Inc.",
        type: InstrumentType = .stock,
        currency: Currency = .usd,
        exchange: String = "NASDAQ",
        isActive: Bool = true
    ) -> Instrument {
        Instrument(id: id, name: name, type: type, currency: currency, exchange: exchange, isActive: isActive)
    }
}

// MARK: - Quote

extension Quote {
    nonisolated static func stub(
        id: String = "AAPL",
        price: Decimal = 150,
        change: Decimal = 2,
        changePercent: Decimal = 1.35,
        volume: Int64 = 1_000_000
    ) -> Quote {
        Quote(id: id, price: price, change: change, changePercent: changePercent, volume: volume)
    }
}

// MARK: - Position

extension Position {
    nonisolated static func stub(
        instrumentID: String = "AAPL",
        instrumentType: InstrumentType = .stock,
        quantity: Decimal = 10,
        averageCostBasis: Decimal = 100,
        currentPrice: Decimal = 150
    ) -> Position {
        Position(
            instrumentID: instrumentID,
            instrumentType: instrumentType,
            quantity: quantity,
            averageCostBasis: averageCostBasis,
            currentPrice: currentPrice
        )
    }
}

// MARK: - Portafolio

extension Portfolio {
    nonisolated static func stub(
        userID: String = "user-1",
        positions: [Position] = [],
        cashBalance: Decimal = 1000,
        currency: Currency = .usd
    ) -> Portfolio {
        Portfolio(userID: userID, positions: positions, cashBalance: cashBalance, currency: currency)
    }
}

// MARK: - Order

extension Order {
    nonisolated static func stub(
        id: String = "order-1",
        instrumentID: String = "AAPL",
        side: OrderSide = .buy,
        type: OrderType = .market,
        quantity: Decimal = 5,
        status: OrderStatus = .filled,
        filledQuantity: Decimal = 5,
        averageFillPrice: Decimal = 150
    ) -> Order {
        Order(
            id: id,
            instrumentID: instrumentID,
            side: side,
            type: type,
            quantity: quantity,
            status: status,
            filledQuantity: filledQuantity,
            averageFillPrice: averageFillPrice
        )
    }
}

// MARK: - UserProfile

extension UserProfile {
    nonisolated static func stub(
        id: String = "user-1",
        kycStatus: KYCStatus = .approved,
        cashBalance: Decimal = 10_000
    ) -> UserProfile {
        UserProfile(
            id: id,
            email: "test@investflow.com",
            firstName: "Test",
            lastName: "User",
            kycStatus: kycStatus,
            riskProfile: .moderate,
            cashBalance: cashBalance,
            currency: .usd
        )
    }
}

// MARK: - Transaction

extension Transaction {
    nonisolated static func stub(
        id: String = "tx-1",
        type: TransactionType = .deposit,
        price: Decimal = 500,
        currency: Currency = .usd,
        executedAt: Date = Date()
    ) -> Transaction {
        Transaction(id: id, type: type, price: price, currency: currency, executedAt: executedAt)
    }
}

// MARK: - WatchlistItem

extension WatchlistItem {
    nonisolated static func stub(
        instrumentID: String = "AAPL",
        addedAt: Date = .distantPast
    ) -> WatchlistItem {
        WatchlistItem(instrumentID: instrumentID, addedAt: addedAt)
    }
}

// MARK: - WatchlistEntry

extension WatchlistEntry {
    nonisolated static func stub(
        instrumentID: String = "AAPL",
        price: Decimal = 150,
        addedAt: Date = .distantPast
    ) -> WatchlistEntry {
        WatchlistEntry(
            item: .stub(instrumentID: instrumentID, addedAt: addedAt),
            marketItem: MarketItem(
                instrument: .stub(id: instrumentID),
                quote: .stub(id: instrumentID, price: price)
            )
        )
    }
}

// MARK: - MockError

enum MockError: Error, Equatable {
    case simulatedFailure
    case notFound
}
