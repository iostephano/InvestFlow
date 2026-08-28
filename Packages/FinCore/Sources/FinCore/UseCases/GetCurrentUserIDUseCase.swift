//
//  GetCurrentUserIDUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetCurrentUserIDUseCase: Sendable {

    private let repository: any AuthRepositoryProtocol

    public init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async -> String? {
        await repository.currentUserID()
    }
}
