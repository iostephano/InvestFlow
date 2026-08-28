//
//  QuoteDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Cotización en tiempo real tal como llega de la API.
/// Precios como String para preservar precisión decimal — se mapean a Decimal en InstrumentMapper.
struct QuoteDTO: Decodable, Sendable {
    let id: String
    let price: String
    let change: String
    let changePercent: String
    let volume: Int64
    let timestamp: Date
}

extension QuoteDTO {
    private enum CodingKeys: CodingKey {
        case id, price, change, changePercent, volume, timestamp
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c         = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        price         = try c.decode(String.self, forKey: .price)
        change        = try c.decode(String.self, forKey: .change)
        changePercent = try c.decode(String.self, forKey: .changePercent)
        volume        = try c.decode(Int64.self,  forKey: .volume)
        timestamp     = try c.decode(Date.self,   forKey: .timestamp)
    }
}
