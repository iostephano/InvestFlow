//
//  OrderDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Orden tal como llega de la API de InvestFlow.
/// Cantidades y precios como String para Decimal sin pérdida de precisión.
struct OrderDTO: Decodable, Sendable {
    let id: String
    let instrumentId: String
    let side: String
    let type: String
    let quantity: String
    let limitPrice: String?
    let stopPrice: String?
    let status: String
    let timeInForce: String
    let filledQuantity: String
    let averageFillPrice: String?
    let placedAt: Date
    let updatedAt: Date
}

extension OrderDTO {
    private enum CodingKeys: CodingKey {
        case id, instrumentId, side, type, quantity, limitPrice, stopPrice
        case status, timeInForce, filledQuantity, averageFillPrice, placedAt, updatedAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c              = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(String.self,          forKey: .id)
        instrumentId       = try c.decode(String.self,          forKey: .instrumentId)
        side               = try c.decode(String.self,          forKey: .side)
        type               = try c.decode(String.self,          forKey: .type)
        quantity           = try c.decode(String.self,          forKey: .quantity)
        limitPrice         = try c.decodeIfPresent(String.self, forKey: .limitPrice)
        stopPrice          = try c.decodeIfPresent(String.self, forKey: .stopPrice)
        status             = try c.decode(String.self,          forKey: .status)
        timeInForce        = try c.decode(String.self,          forKey: .timeInForce)
        filledQuantity     = try c.decode(String.self,          forKey: .filledQuantity)
        averageFillPrice   = try c.decodeIfPresent(String.self, forKey: .averageFillPrice)
        placedAt           = try c.decode(Date.self,            forKey: .placedAt)
        updatedAt          = try c.decode(Date.self,            forKey: .updatedAt)
    }
}
