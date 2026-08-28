//
//  OrderMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum OrderMapper {

    nonisolated static func map(_ dto: OrderDTO) -> Order? {
        guard
            let side        = OrderSide(rawValue: dto.side),
            let type        = OrderType(rawValue: dto.type),
            let status      = OrderStatus(rawValue: dto.status),
            let tif         = TimeInForce(rawValue: dto.timeInForce),
            let quantity    = Decimal(string: dto.quantity),
            let filled      = Decimal(string: dto.filledQuantity)
        else { return nil }

        return Order(
            id:               dto.id,
            instrumentID:     dto.instrumentId,
            side:             side,
            type:             type,
            quantity:         quantity,
            limitPrice:       dto.limitPrice.flatMap { Decimal(string: $0) },
            stopPrice:        dto.stopPrice.flatMap { Decimal(string: $0) },
            status:           status,
            timeInForce:      tif,
            filledQuantity:   filled,
            averageFillPrice: dto.averageFillPrice.flatMap { Decimal(string: $0) },
            placedAt:         dto.placedAt,
            updatedAt:        dto.updatedAt
        )
    }

    nonisolated static func map(_ dtos: [OrderDTO]) -> [Order] {
        dtos.compactMap { map($0) }
    }
}
