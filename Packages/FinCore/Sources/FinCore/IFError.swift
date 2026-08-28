//
//  IFError.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Error domain unificado de InvestFlow. Toda la capa de presentación
/// distingue errores usando este tipo en lugar de genéricos.
public enum IFError: Error, Sendable, Equatable {
    case notFound(String)
    case unauthorized
    case networkUnavailable
    case serverError(statusCode: Int)
    case validationFailed(String)
    case unknown(String)
}

extension IFError {
    public static func from(_ error: Error) -> IFError {
        (error as? IFError) ?? .unknown(error.localizedDescription)
    }

    public var userMessage: String {
        switch self {
        case .notFound(let resource):
            return "No encontramos \(resource)."
        case .unauthorized:
            return "Sesión expirada. Vuelve a iniciar sesión."
        case .networkUnavailable:
            return "Sin conexión. Revisa tu internet e intenta de nuevo."
        case .serverError(let code):
            return "Error del servidor (\(code)). Intenta más tarde."
        case .validationFailed(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}
