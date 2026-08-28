//
//  PortfolioDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

struct PortfolioDTO: Decodable, Sendable {
    let userId: String
    let positions: [PositionDTO]
    let cashBalance: String
    let currency: String
    let updatedAt: Date

    private enum CodingKeys: CodingKey {
        case userId, positions, cashBalance, currency, updatedAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c       = try decoder.container(keyedBy: CodingKeys.self)
        userId      = try c.decode(String.self,       forKey: .userId)
        positions   = try c.decode([PositionDTO].self, forKey: .positions)
        cashBalance = try c.decode(String.self,       forKey: .cashBalance)
        currency    = try c.decode(String.self,       forKey: .currency)
        updatedAt   = try c.decode(Date.self,         forKey: .updatedAt)
    }
}
