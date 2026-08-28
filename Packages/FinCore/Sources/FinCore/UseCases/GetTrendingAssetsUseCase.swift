//
//  GetTrendingAssetsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetTrendingAssetsUseCase: Sendable {

    public init() {}

    /// Devuelve los activos ordenados por volumen de negociación — proxy de la actividad del mercado.
    public func execute(from items: [MarketItem], limit: Int = 6) -> [MarketItem] {
        Array(
            items
                .sorted { $0.quote.volume > $1.quote.volume }
                .prefix(limit)
        )
    }
}
