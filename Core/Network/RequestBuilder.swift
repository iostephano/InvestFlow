//
//  RequestBuilder.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Construye URLRequest a partir de un Endpoint + token de acceso opcional.
public struct RequestBuilder: Sendable {

    private let environment: AppEnvironment

    public init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    public func build(_ endpoint: any Endpoint, accessToken: String?) throws -> URLRequest {
        guard var components = URLComponents(
            url: environment.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        ) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: environment.requestTimeout)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = accessToken, endpoint.requiresAuth {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.additionalHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = endpoint.bodyData {
            request.httpBody = body
        }

        return request
    }
}
