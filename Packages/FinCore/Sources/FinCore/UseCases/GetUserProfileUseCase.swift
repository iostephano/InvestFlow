//
//  GetUserProfileUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetUserProfileUseCase: Sendable {

    private let repository: any PortfolioRepositoryProtocol

    public init(repository: any PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userID: String) async throws -> UserProfile {
        try await repository.fetchUserProfile(for: userID)
    }
}
