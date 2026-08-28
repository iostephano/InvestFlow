//
//  TopMovers.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct TopMovers: Sendable {
    public let gainers: [MarketItem]
    public let losers: [MarketItem]

    public init(gainers: [MarketItem], losers: [MarketItem]) {
        self.gainers = gainers
        self.losers = losers
    }

    public static let empty = TopMovers(gainers: [], losers: [])
}
