//
//  TransactionMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum TransactionMapper {

    nonisolated static func map(_ dto: TransactionDTO) -> Transaction? {
        guard
            let type     = TransactionType(rawValue: dto.type),
            let price    = Decimal(string: dto.price),
            let fee      = Decimal(string: dto.fee),
            let currency = Currency(rawValue: dto.currency)
        else { return nil }

        return Transaction(
            id:           dto.id,
            orderID:      dto.orderId,
            instrumentID: dto.instrumentId,
            type:         type,
            quantity:     dto.quantity.flatMap { Decimal(string: $0) },
            price:        price,
            fee:          fee,
            currency:     currency,
            executedAt:   dto.executedAt
        )
    }

    nonisolated static func map(_ dtos: [TransactionDTO]) -> [Transaction] {
        dtos.compactMap { map($0) }
    }
}
