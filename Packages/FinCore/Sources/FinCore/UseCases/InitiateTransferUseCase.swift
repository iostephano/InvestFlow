//
//  InitiateTransferUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public enum TransferValidationError: LocalizedError, Sendable {
    case amountTooLow(minimum: Decimal)
    case amountTooHigh(maximum: Decimal)
    case methodUnavailable

    public var errorDescription: String? {
        switch self {
        case .amountTooLow(let min):  return "El monto mínimo es \(min) USD"
        case .amountTooHigh(let max): return "El monto máximo es \(max) USD"
        case .methodUnavailable:      return "Este método no está disponible"
        }
    }
}

public struct InitiateTransferUseCase: Sendable {

    private let repository: any TransferRepositoryProtocol

    public init(repository: any TransferRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ request: TransferRequest) async throws -> TransferResult {
        guard request.method.isAvailable else {
            throw TransferValidationError.methodUnavailable
        }
        guard request.amount >= request.method.minAmount else {
            throw TransferValidationError.amountTooLow(minimum: request.method.minAmount)
        }
        guard request.amount <= request.method.maxAmount else {
            throw TransferValidationError.amountTooHigh(maximum: request.method.maxAmount)
        }
        return try await repository.initiateTransfer(request)
    }
}
