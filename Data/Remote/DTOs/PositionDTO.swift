//
//  PositionDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

struct PositionDTO: Decodable, Sendable {
    let instrumentId: String
    let instrumentType: String?
    let quantity: String
    let averageCostBasis: String
    let currentPrice: String
}

extension PositionDTO {
    private enum CodingKeys: CodingKey {
        case instrumentId, instrumentType, quantity, averageCostBasis, currentPrice
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c            = try decoder.container(keyedBy: CodingKeys.self)
        instrumentId     = try c.decode(String.self,          forKey: .instrumentId)
        instrumentType   = try c.decodeIfPresent(String.self, forKey: .instrumentType)
        quantity         = try c.decode(String.self,          forKey: .quantity)
        averageCostBasis = try c.decode(String.self,          forKey: .averageCostBasis)
        currentPrice     = try c.decode(String.self,          forKey: .currentPrice)
    }
}
