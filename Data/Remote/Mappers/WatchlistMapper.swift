//
//  WatchlistMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

enum WatchlistMapper {

    nonisolated static func map(_ dto: WatchlistItemDTO) -> WatchlistItem {
        WatchlistItem(instrumentID: dto.instrumentId, addedAt: dto.addedAt)
    }

    nonisolated static func map(_ dtos: [WatchlistItemDTO]) -> [WatchlistItem] {
        dtos.map { map($0) }
    }
}
