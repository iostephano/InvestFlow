//
//  GetPortfolioUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetPortfolioUseCase: Sendable {

    private let repository: any PortfolioRepositoryProtocol

    public init(repository: any PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userID: String) async throws -> Portfolio {
        try await repository.fetchPortfolio(for: userID)
    }

    public func invalidateCache(for userID: String) async {
        await repository.invalidateCache(for: userID)
    }
}
