//
//  KYCValidationResult.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// Resultado de validar el estado KYC del usuario para operar transferencias.
public enum KYCValidationResult: Sendable {
    case approved
    case requiresVerification(KYCStatus)
    case rejected(reason: String)

    public var isApproved: Bool {
        if case .approved = self { return true }
        return false
    }
}
