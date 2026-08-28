//
//  UserProfileMapper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

enum UserProfileMapper {

    nonisolated static func map(_ dto: UserProfileDTO) -> UserProfile? {
        guard
            let kycStatus    = KYCStatus(rawValue: dto.kycStatus),
            let riskProfile  = RiskProfile(rawValue: dto.riskProfile),
            let cashBalance  = Decimal(string: dto.cashBalance),
            let currency     = Currency(rawValue: dto.currency)
        else { return nil }

        return UserProfile(
            id:          dto.id,
            email:       dto.email,
            firstName:   dto.firstName,
            lastName:    dto.lastName,
            kycStatus:   kycStatus,
            riskProfile: riskProfile,
            cashBalance: cashBalance,
            currency:    currency,
            createdAt:   dto.createdAt
        )
    }
}
