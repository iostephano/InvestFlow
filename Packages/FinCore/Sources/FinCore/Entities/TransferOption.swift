//
//  TransferOption.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

public enum TransferMethod: String, Codable, Hashable, Sendable {
    case bankTransfer = "BANK_TRANSFER"
    case debitCard    = "DEBIT_CARD"
    case crypto       = "CRYPTO"
    case wire         = "WIRE"
}

/// Método de transferencia disponible para un país dado.
public struct TransferOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let method: TransferMethod
    public let name: String
    public let description: String
    public let minAmount: Decimal
    public let maxAmount: Decimal
    public let estimatedTime: String
    /// Importe de la comisión. Interpretación según `feeIsPercentage`.
    public let fee: Decimal
    /// `true` → `fee` es tasa (0.015 = 1.5%). `false` → monto fijo en USD.
    public let feeIsPercentage: Bool
    public let isAvailable: Bool

    public init(
        id: String,
        method: TransferMethod,
        name: String,
        description: String,
        minAmount: Decimal,
        maxAmount: Decimal,
        estimatedTime: String,
        fee: Decimal = .zero,
        feeIsPercentage: Bool = false,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.method = method
        self.name = name
        self.description = description
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.estimatedTime = estimatedTime
        self.fee = fee
        self.feeIsPercentage = feeIsPercentage
        self.isAvailable = isAvailable
    }
}
