//
//  InstrumentMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum InstrumentMapper {

    nonisolated static func map(_ dto: InstrumentDTO) -> Instrument? {
        guard
            let type = InstrumentType(rawValue: dto.type),
            let currency = Currency(rawValue: dto.currency)
        else { return nil }

        return Instrument(
            id:       dto.id,
            name:     dto.name,
            type:     type,
            currency: currency,
            logoURL:  dto.logoUrl.flatMap(URL.init(string:)),
            exchange: dto.exchange,
            isActive: dto.isActive
        )
    }

    nonisolated static func map(_ dtos: [InstrumentDTO]) -> [Instrument] {
        dtos.compactMap { map($0) }
    }
}
