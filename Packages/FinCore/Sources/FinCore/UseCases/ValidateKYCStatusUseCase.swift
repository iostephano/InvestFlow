//
//  ValidateKYCStatusUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// Devuelve el resultado de validación KYC del usuario para determinar si puede transferir.
public struct ValidateKYCStatusUseCase: Sendable {

    private let portfolioRepository: any PortfolioRepositoryProtocol

    public init(portfolioRepository: any PortfolioRepositoryProtocol) {
        self.portfolioRepository = portfolioRepository
    }

    public func execute(userID: String) async throws -> KYCValidationResult {
        let profile = try await portfolioRepository.fetchUserProfile(for: userID)
        switch profile.kycStatus {
        case .approved:
            return .approved
        case .pending, .inReview:
            return .requiresVerification(profile.kycStatus)
        case .rejected:
            return .rejected(reason: "Tu verificación de identidad fue rechazada. Contacta a soporte.")
        }
    }
}
