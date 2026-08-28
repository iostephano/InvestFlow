//
//  BiometricsHelper.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import LocalAuthentication

public enum BiometricsError: Error, Sendable {
    case notAvailable
    case notEnrolled
    case authenticationFailed
    case userCancelled
    case systemCancelled
    case lockout
    case unknown(Int)
}

public enum BiometryType: Sendable {
    case faceID
    case touchID
    case opticID
    case none
}

/// Abstracción sobre LocalAuthentication para autenticación biométrica en InvestFlow.
/// Usada para confirmar operaciones sensibles (órdenes, retiros).
public struct BiometricsHelper: Sendable {

    public nonisolated init() {}

    public var biometryType: BiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID:   return .faceID
        case .touchID:  return .touchID
        case .opticID:  return .opticID
        default:        return .none
        }
    }

    public var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Solicita autenticación biométrica. Lanza si falla o el usuario cancela.
    public func authenticate(reason: String) async throws {
        let context = LAContext()

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw BiometricsError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            if !success { throw BiometricsError.authenticationFailed }
        } catch let laError as LAError {
            throw biometricsError(from: laError)
        }
    }

    private func biometricsError(from error: LAError) -> BiometricsError {
        switch error.code {
        case .authenticationFailed:       return .authenticationFailed
        case .userCancel:                 return .userCancelled
        case .systemCancel:               return .systemCancelled
        case .biometryNotAvailable:       return .notAvailable
        case .biometryNotEnrolled:        return .notEnrolled
        case .biometryLockout:            return .lockout
        default:                          return .unknown(error.code.rawValue)
        }
    }
}
