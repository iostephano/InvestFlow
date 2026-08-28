//
//  WatchlistRequestDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

/// Cuerpo de la solicitud para agregar un instrumento a la watchlist.
/// encode(to:) marcado nonisolated para poder usarse desde métodos nonisolated
/// de WatchlistRepositoryLive sin necesitar @MainActor (-default-isolation MainActor).
struct WatchlistRequestDTO: Encodable, Sendable {
    let instrumentId: String

    private enum CodingKeys: String, CodingKey {
        case instrumentId = "instrument_id"
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrumentId, forKey: .instrumentId)
    }
}
