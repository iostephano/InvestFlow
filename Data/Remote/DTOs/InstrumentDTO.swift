//
//  InstrumentDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// DTO de instrumento financiero tal como llega de la API de InvestFlow.
/// convertFromSnakeCase en JSONDecoder.investFlow maneja is_active → isActive, logo_url → logoUrl.
struct InstrumentDTO: Decodable, Sendable {
    let id: String
    let name: String
    let type: String
    let currency: String
    let logoUrl: String?
    let exchange: String
    let isActive: Bool
}

extension InstrumentDTO {
    private enum CodingKeys: CodingKey {
        case id, name, type, currency, logoUrl, exchange, isActive
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c    = try decoder.container(keyedBy: CodingKeys.self)
        id       = try c.decode(String.self, forKey: .id)
        name     = try c.decode(String.self, forKey: .name)
        type     = try c.decode(String.self, forKey: .type)
        currency = try c.decode(String.self, forKey: .currency)
        logoUrl  = try c.decodeIfPresent(String.self, forKey: .logoUrl)
        exchange = try c.decode(String.self, forKey: .exchange)
        isActive = try c.decode(Bool.self, forKey: .isActive)
    }
}
