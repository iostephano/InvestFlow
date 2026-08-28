//
//  Transaction.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public enum TransactionType: String, Codable, Sendable {
    case buy        = "BUY"
    case sell       = "SELL"
    case dividend   = "DIVIDEND"
    case fee        = "FEE"
    case deposit    = "DEPOSIT"
    case withdrawal = "WITHDRAWAL"
}

/// Registro inmutable de una operación completada en InvestFlow.
/// A diferencia de Order, Transaction representa el hecho contable consumado.
public struct Transaction: Identifiable, Sendable {
    public let id: String
    public let orderID: String?
    public let instrumentID: String?
    public let type: TransactionType
    public let quantity: Decimal?
    public let price: Decimal
    public let fee: Decimal
    public let currency: Currency
    public let executedAt: Date

    /// Impacto neto en el balance de cash del usuario.
    public var netAmount: Decimal {
        switch type {
        case .buy:
            return -((price * (quantity ?? 1)) + fee)
        case .sell:
            return (price * (quantity ?? 1)) - fee
        case .dividend:
            return price - fee
        case .fee:
            return -fee
        case .deposit:
            return price
        case .withdrawal:
            return -price
        }
    }

    public var grossAmount: Decimal {
        switch type {
        case .buy:        return -(price * (quantity ?? 1))
        case .sell:       return price * (quantity ?? 1)
        case .dividend:   return price
        case .fee:        return .zero
        case .deposit:    return price
        case .withdrawal: return -price
        }
    }

    public init(
        id: String,
        orderID: String? = nil,
        instrumentID: String? = nil,
        type: TransactionType,
        quantity: Decimal? = nil,
        price: Decimal,
        fee: Decimal = .zero,
        currency: Currency,
        executedAt: Date = Date()
    ) {
        self.id = id
        self.orderID = orderID
        self.instrumentID = instrumentID
        self.type = type
        self.quantity = quantity
        self.price = price
        self.fee = fee
        self.currency = currency
        self.executedAt = executedAt
    }
}
