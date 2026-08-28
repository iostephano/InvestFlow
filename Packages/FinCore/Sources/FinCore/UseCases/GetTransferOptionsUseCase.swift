//
//  GetTransferOptionsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// Devuelve los métodos de transferencia disponibles para un país y dirección dados.
public struct GetTransferOptionsUseCase: Sendable {

    private let repository: any TransferRepositoryProtocol

    public init(repository: any TransferRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(countryID: String, flowType: TransferFlowType) async throws -> [TransferOption] {
        let options = try await repository.fetchTransferOptions(for: countryID, flowType: flowType)
        return options.filter { $0.isAvailable }
    }
}
