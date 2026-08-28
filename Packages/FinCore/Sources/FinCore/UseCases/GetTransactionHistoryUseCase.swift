//
//  GetTransactionHistoryUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetTransactionHistoryUseCase: Sendable {

    private let repository: any PortfolioRepositoryProtocol

    public init(repository: any PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userID: String, limit: Int = 200) async throws -> [Transaction] {
        try await repository.fetchTransactions(for: userID, limit: limit)
    }

    /// Invalida los datos cacheados de `userID` y luego trae transacciones frescas.
    /// Lo usan los flujos de pull-to-refresh donde hay que saltarse la caché obsoleta.
    public func reload(userID: String, limit: Int = 200) async throws -> [Transaction] {
        await repository.invalidateCache(for: userID)
        return try await repository.fetchTransactions(for: userID, limit: limit)
    }
}
