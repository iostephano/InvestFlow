//
//  TransactionDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

struct TransactionDTO: Decodable, Sendable {
    let id: String
    let orderId: String?
    let instrumentId: String?
    let type: String
    let quantity: String?
    let price: String
    let fee: String
    let currency: String
    let executedAt: Date
}

extension TransactionDTO {
    private enum CodingKeys: CodingKey {
        case id, orderId, instrumentId, type, quantity, price, fee, currency, executedAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(String.self,          forKey: .id)
        orderId      = try c.decodeIfPresent(String.self, forKey: .orderId)
        instrumentId = try c.decodeIfPresent(String.self, forKey: .instrumentId)
        type         = try c.decode(String.self,          forKey: .type)
        quantity     = try c.decodeIfPresent(String.self, forKey: .quantity)
        price        = try c.decode(String.self,          forKey: .price)
        fee          = try c.decode(String.self,          forKey: .fee)
        currency     = try c.decode(String.self,          forKey: .currency)
        executedAt   = try c.decode(Date.self,            forKey: .executedAt)
    }
}
