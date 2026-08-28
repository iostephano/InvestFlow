//
//  AssetCategory.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public enum AssetCategory: String, CaseIterable, Identifiable, Sendable {
    case all        = "all"
    case stocks     = "STOCK"
    case etfs       = "ETF"
    case crypto     = "CRYPTO"
    case portfolios = "PORTFOLIO"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .all:        return "Todos"
        case .stocks:     return "Acciones"
        case .etfs:       return "ETFs"
        case .crypto:     return "Crypto"
        case .portfolios: return "Portafolios"
        }
    }

    public var instrumentType: InstrumentType? {
        switch self {
        case .all:        return nil
        case .stocks:     return .stock
        case .etfs:       return .etf
        case .crypto:     return .crypto
        case .portfolios: return .portfolio
        }
    }
}
