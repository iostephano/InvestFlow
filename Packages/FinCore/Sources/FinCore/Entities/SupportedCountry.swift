//
//  SupportedCountry.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// País soportado para operaciones de depósito/retiro en InvestFlow.
public struct SupportedCountry: Identifiable, Hashable, Sendable {

    /// Código ISO 3166-1 alpha-2 (ej. "PE", "MX", "US").
    public let id: String
    public let name: String
    public let flagEmoji: String
    public let dialCode: String
    public let isSupported: Bool
    public let requiredKYCLevel: KYCStatus

    public init(
        id: String,
        name: String,
        flagEmoji: String,
        dialCode: String,
        isSupported: Bool,
        requiredKYCLevel: KYCStatus = .approved
    ) {
        self.id = id
        self.name = name
        self.flagEmoji = flagEmoji
        self.dialCode = dialCode
        self.isSupported = isSupported
        self.requiredKYCLevel = requiredKYCLevel
    }
}
