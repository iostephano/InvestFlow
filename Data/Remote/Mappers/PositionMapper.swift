//
//  PositionMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum PositionMapper {

    nonisolated static func map(_ dto: PositionDTO) -> Position? {
        guard
            let quantity         = Decimal(string: dto.quantity),
            let averageCostBasis = Decimal(string: dto.averageCostBasis),
            let currentPrice     = Decimal(string: dto.currentPrice)
        else { return nil }

        let instrumentType = dto.instrumentType.flatMap { InstrumentType(rawValue: $0) } ?? .stock

        return Position(
            instrumentID:     dto.instrumentId,
            instrumentType:   instrumentType,
            quantity:         quantity,
            averageCostBasis: averageCostBasis,
            currentPrice:     currentPrice
        )
    }

    nonisolated static func map(_ dtos: [PositionDTO]) -> [Position] {
        dtos.compactMap { map($0) }
    }
}
