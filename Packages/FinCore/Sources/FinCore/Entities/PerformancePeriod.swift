//
//  PerformancePeriod.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public enum PerformancePeriod: String, CaseIterable, Identifiable, Sendable {
    case oneYear    = "1A"
    case threeYears = "3A"
    case fiveYears  = "5A"

    public var id: String { rawValue }

    public var years: Int {
        switch self {
        case .oneYear:    return 1
        case .threeYears: return 3
        case .fiveYears:  return 5
        }
    }

    /// Puntos de datos mensuales del período.
    public var monthCount: Int { years * 12 }
}
