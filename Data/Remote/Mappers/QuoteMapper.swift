//
//  QuoteMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum QuoteMapper {

    nonisolated static func map(_ dto: QuoteDTO) -> Quote? {
        guard
            let price         = Decimal(string: dto.price),
            let change        = Decimal(string: dto.change),
            let changePercent = Decimal(string: dto.changePercent)
        else { return nil }

        return Quote(
            id:            dto.id,
            price:         price,
            change:        change,
            changePercent: changePercent,
            volume:        dto.volume,
            timestamp:     dto.timestamp
        )
    }

    nonisolated static func map(_ dtos: [QuoteDTO]) -> [Quote] {
        dtos.compactMap { map($0) }
    }
}
