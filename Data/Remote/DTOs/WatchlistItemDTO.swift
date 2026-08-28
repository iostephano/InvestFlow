//
//  WatchlistItemDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// DTO de ítem de watchlist tal como llega de la API de InvestFlow.
/// convertFromSnakeCase en JSONDecoder.investFlow maneja instrument_id → instrumentId, added_at → addedAt.
struct WatchlistItemDTO: Decodable, Sendable {
    let instrumentId: String
    let addedAt: Date
}

extension WatchlistItemDTO {
    private enum CodingKeys: CodingKey {
        case instrumentId, addedAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        instrumentId = try c.decode(String.self, forKey: .instrumentId)
        addedAt      = try c.decode(Date.self,   forKey: .addedAt)
    }
}
