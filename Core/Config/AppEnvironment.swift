//
//  AppEnvironment.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public enum AppEnvironment: Sendable {
    case development
    case staging
    case production

    /// Lee APP_ENVIRONMENT del entorno del proceso (se define en el scheme de Xcode →
    /// Run → Arguments → Environment Variables) y, si no está, cae al flag DEBUG.
    /// Usar ProcessInfo evita la inferencia @MainActor que Bundle.main arrastra en targets UIKit.
    public nonisolated static var current: AppEnvironment {
        switch ProcessInfo.processInfo.environment["APP_ENVIRONMENT"] {
        case "staging":    return .staging
        case "production": return .production
        default:           break
        }
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    public var baseURL: URL {
        switch self {
        case .development: return URL(string: "https://api-dev.investflow.com/v1")!
        case .staging:     return URL(string: "https://api-staging.investflow.com/v1")!
        case .production:  return URL(string: "https://api.investflow.com/v1")!
        }
    }

    public nonisolated var isDebug: Bool {
        if case .development = self { return true }
        return false
    }

    public var requestTimeout: TimeInterval {
        switch self {
        case .development: return 30
        case .staging:     return 20
        case .production:  return 15
        }
    }
}
