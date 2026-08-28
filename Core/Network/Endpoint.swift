//
//  Endpoint.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

public enum HTTPMethod: String, Sendable {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
    case patch  = "PATCH"
}

/// Contrato que todo endpoint de InvestFlow debe cumplir.
/// El cuerpo se provee pre-codificado en Data para evitar dependencias
/// del protocolo con tipos externos (Encodable genérico).
public protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyData: Data? { get }
    var requiresAuth: Bool { get }
    var additionalHeaders: [String: String] { get }
}

public extension Endpoint {
    var queryItems: [URLQueryItem]? { nil }
    var bodyData: Data? { nil }
    var requiresAuth: Bool { true }
    var additionalHeaders: [String: String] { [:] }
}
