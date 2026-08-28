//
//  UserProfile.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public enum KYCStatus: String, Codable, Sendable {
    case pending  = "PENDING"
    case inReview = "IN_REVIEW"
    case approved = "APPROVED"
    case rejected = "REJECTED"
}

public enum RiskProfile: String, Codable, Sendable {
    case conservative = "CONSERVATIVE"
    case moderate     = "MODERATE"
    case aggressive   = "AGGRESSIVE"
}

/// Perfil del usuario autenticado en InvestFlow.
/// Contiene estado KYC, perfil de riesgo y balance disponible.
public struct UserProfile: Identifiable, Sendable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let kycStatus: KYCStatus
    public let riskProfile: RiskProfile
    public let cashBalance: Decimal
    public let currency: Currency
    public let createdAt: Date

    public var fullName: String { "\(firstName) \(lastName)" }

    /// Solo usuarios con KYC aprobado pueden operar en InvestFlow.
    public var canTrade: Bool { kycStatus == .approved }

    /// Usuario con KYC pendiente — muestra flujo de onboarding.
    public var needsOnboarding: Bool { kycStatus == .pending }

    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        kycStatus: KYCStatus,
        riskProfile: RiskProfile,
        cashBalance: Decimal,
        currency: Currency,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.kycStatus = kycStatus
        self.riskProfile = riskProfile
        self.cashBalance = cashBalance
        self.currency = currency
        self.createdAt = createdAt
    }
}
