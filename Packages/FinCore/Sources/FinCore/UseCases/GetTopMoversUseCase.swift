//
//  GetTopMoversUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetTopMoversUseCase: Sendable {

    public init() {}

    public func execute(from items: [MarketItem], limit: Int = 5) -> TopMovers {
        let sorted = items.sorted { $0.quote.changePercent > $1.quote.changePercent }
        let gainers = Array(sorted.prefix(limit))
        let losers  = Array(sorted.suffix(limit).reversed())
        return TopMovers(gainers: gainers, losers: losers)
    }
}
