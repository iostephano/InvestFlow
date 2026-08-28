//
//  PortfolioMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum PortfolioMapper {

    nonisolated static func map(_ dto: PortfolioDTO) -> Portfolio? {
        guard
            let cashBalance = Decimal(string: dto.cashBalance),
            let currency    = Currency(rawValue: dto.currency)
        else { return nil }

        let positions = PositionMapper.map(dto.positions)

        return Portfolio(
            userID:      dto.userId,
            positions:   positions,
            cashBalance: cashBalance,
            currency:    currency,
            updatedAt:   dto.updatedAt
        )
    }
}
