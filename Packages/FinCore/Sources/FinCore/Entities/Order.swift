//
//  Order.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public enum OrderSide: String, Codable, Sendable {
    case buy  = "BUY"
    case sell = "SELL"
}

public enum OrderType: String, Codable, Sendable {
    case market    = "MARKET"
    case limit     = "LIMIT"
    case stopLoss  = "STOP_LOSS"
    case stopLimit = "STOP_LIMIT"
}

public enum OrderStatus: String, Codable, Sendable {
    case pending         = "PENDING"
    case filled          = "FILLED"
    case partiallyFilled = "PARTIALLY_FILLED"
    case cancelled       = "CANCELLED"
    case rejected        = "REJECTED"
    case expired         = "EXPIRED"
}

public enum TimeInForce: String, Codable, Sendable {
    case day = "DAY"
    case gtc = "GTC"
    case ioc = "IOC"
    case fok = "FOK"
}

public struct OrderRequest: Sendable {
    public let instrumentID: String
    public let side: OrderSide
    public let type: OrderType
    public let quantity: Decimal
    public let limitPrice: Decimal?
    public let stopPrice: Decimal?
    public let timeInForce: TimeInForce
    /// Lo usa PlaceOrderUseCase para verificar que hay cash suficiente en órdenes market.
    public let estimatedMarketPrice: Decimal?

    public init(
        instrumentID: String,
        side: OrderSide,
        type: OrderType,
        quantity: Decimal,
        limitPrice: Decimal? = nil,
        stopPrice: Decimal? = nil,
        timeInForce: TimeInForce = .day,
        estimatedMarketPrice: Decimal? = nil
    ) {
        self.instrumentID = instrumentID
        self.side = side
        self.type = type
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.stopPrice = stopPrice
        self.timeInForce = timeInForce
        self.estimatedMarketPrice = estimatedMarketPrice
    }
}

public struct Order: Identifiable, Equatable, Sendable {
    public let id: String
    public let instrumentID: String
    public let side: OrderSide
    public let type: OrderType
    public let quantity: Decimal
    public let limitPrice: Decimal?
    public let stopPrice: Decimal?
    public let status: OrderStatus
    public let timeInForce: TimeInForce
    public let filledQuantity: Decimal
    public let averageFillPrice: Decimal?
    public let placedAt: Date
    public let updatedAt: Date

    public var isPending: Bool        { status == .pending }
    public var isFilled: Bool         { status == .filled }
    public var isActive: Bool         { status == .pending || status == .partiallyFilled }
    public var remainingQuantity: Decimal { quantity - filledQuantity }

    /// Valor ejecutado de la porción ya llenada (mark-to-market del fill).
    public var filledValue: Decimal? {
        guard filledQuantity > .zero, let price = averageFillPrice else { return nil }
        return price * filledQuantity
    }

    /// Valor estimado de la orden completa (para órdenes límite pendientes).
    public var estimatedValue: Decimal? {
        guard let price = limitPrice ?? stopPrice else { return nil }
        return price * quantity
    }

    public init(
        id: String,
        instrumentID: String,
        side: OrderSide,
        type: OrderType,
        quantity: Decimal,
        limitPrice: Decimal? = nil,
        stopPrice: Decimal? = nil,
        status: OrderStatus = .pending,
        timeInForce: TimeInForce = .day,
        filledQuantity: Decimal = .zero,
        averageFillPrice: Decimal? = nil,
        placedAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.instrumentID = instrumentID
        self.side = side
        self.type = type
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.stopPrice = stopPrice
        self.status = status
        self.timeInForce = timeInForce
        self.filledQuantity = filledQuantity
        self.averageFillPrice = averageFillPrice
        self.placedAt = placedAt
        self.updatedAt = updatedAt
    }

    public func withStatus(_ newStatus: OrderStatus) -> Order {
        Order(
            id:               id,
            instrumentID:     instrumentID,
            side:             side,
            type:             type,
            quantity:         quantity,
            limitPrice:       limitPrice,
            stopPrice:        stopPrice,
            status:           newStatus,
            timeInForce:      timeInForce,
            filledQuantity:   filledQuantity,
            averageFillPrice: averageFillPrice,
            placedAt:         placedAt,
            updatedAt:        Date()
        )
    }
}
