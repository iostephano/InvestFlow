//
//  UserProfileDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

struct UserProfileDTO: Decodable, Sendable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let kycStatus: String
    let riskProfile: String
    let cashBalance: String
    let currency: String
    let createdAt: Date

    private enum CodingKeys: CodingKey {
        case id, email, firstName, lastName, kycStatus, riskProfile, cashBalance, currency, createdAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(String.self, forKey: .id)
        email       = try c.decode(String.self, forKey: .email)
        firstName   = try c.decode(String.self, forKey: .firstName)
        lastName    = try c.decode(String.self, forKey: .lastName)
        kycStatus   = try c.decode(String.self, forKey: .kycStatus)
        riskProfile = try c.decode(String.self, forKey: .riskProfile)
        cashBalance = try c.decode(String.self, forKey: .cashBalance)
        currency    = try c.decode(String.self, forKey: .currency)
        createdAt   = try c.decode(Date.self,   forKey: .createdAt)
    }
}
