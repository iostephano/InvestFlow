//
//  Quote.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public struct Quote: Identifiable, Sendable {
    public let id: String
    public let price: Decimal
    public let change: Decimal
    public let changePercent: Decimal
    public let volume: Int64
    public let timestamp: Date

    public var isPositive: Bool {
        change >= .zero
    }
    
    public init(
        id: String,
        price: Decimal,
        change: Decimal,
        changePercent: Decimal,
        volume: Int64,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.price = price
        self.change = change
        self.changePercent = changePercent
        self.volume = volume
        self.timestamp = timestamp
    }
}
