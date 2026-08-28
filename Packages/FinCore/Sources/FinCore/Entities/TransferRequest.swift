//
//  TransferRequest.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct TransferRequest: Sendable, Hashable {
    public let userID: String
    public let method: TransferOption
    public let amount: Decimal
    public let currency: String

    public init(userID: String, method: TransferOption, amount: Decimal, currency: String) {
        self.userID = userID
        self.method = method
        self.amount = amount
        self.currency = currency
    }
}

public enum TransferStatus: Sendable, Hashable {
    case pending
    case processing
    case completed
    case failed(String)
}

public struct TransferResult: Sendable, Hashable {
    public let transactionID: String
    public let status: TransferStatus
    public let estimatedArrival: Date?

    public init(transactionID: String, status: TransferStatus, estimatedArrival: Date? = nil) {
        self.transactionID = transactionID
        self.status = status
        self.estimatedArrival = estimatedArrival
    }
}
