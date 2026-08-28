//
//  NetworkErrorMapping.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore

/// Convierte cualquier error de red al dominio IFError unificado.
/// Usado por todos los repositorios Live para que la capa de presentación
/// no distinga entre NetworkError y URLError.
nonisolated func mapToIFError(_ error: Error) -> IFError {
    if let ifError = error as? IFError { return ifError }

    if let networkErr = error as? NetworkError {
        switch networkErr {
        case .unauthorized, .sessionExpired:
            return .unauthorized
        case .requestFailed(let code) where code == 404:
            return .notFound("el recurso solicitado")
        case .requestFailed(let code):
            return .serverError(statusCode: code)
        case .serverError(let code, _):
            return .serverError(statusCode: code)
        case .cancelled:
            return .networkUnavailable
        case .invalidURL, .decodingFailed, .invalidResponse:
            return .unknown(String(describing: networkErr))
        }
    }

    if let urlErr = error as? URLError {
        switch urlErr.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost:
            return .networkUnavailable
        default:
            return .unknown(urlErr.localizedDescription)
        }
    }

    return .unknown(String(describing: error))
}
