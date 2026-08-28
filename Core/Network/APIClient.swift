//
//  APIClient.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - Errores

public enum NetworkError: Error, Sendable, Equatable {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed(String)
    case sessionExpired
    case unauthorized
    case serverError(statusCode: Int, message: String?)
    case cancelled
}

// MARK: - Protocolo

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
    func requestVoid(_ endpoint: any Endpoint) async throws
}

// MARK: - Implementación

/// Cliente HTTP central de InvestFlow.
/// Gestiona autenticación, reintento tras 401 y decodificación.
public final class APIClient: APIClientProtocol, Sendable {

    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private let tokenInterceptor: TokenRefreshInterceptor

    public init(
        session: URLSession = URLSession(configuration: .investFlowFintech),
        requestBuilder: RequestBuilder,
        tokenInterceptor: TokenRefreshInterceptor
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.tokenInterceptor = tokenInterceptor
    }

    // MARK: - Peticiones

    public func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let urlRequest = try buildRequest(for: endpoint)
        let (data, response) = try await performRequest(urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if http.statusCode == 401 {
            return try await retryAfterRefresh(endpoint: endpoint)
        }

        try validate(statusCode: http.statusCode)
        return try decode(data)
    }

    public func requestVoid(_ endpoint: any Endpoint) async throws {
        let urlRequest = try buildRequest(for: endpoint)
        let (_, response) = try await performRequest(urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if http.statusCode == 401 {
            let newToken = try await refreshCurrentToken()
            let retryRequest = try requestBuilder.build(endpoint, accessToken: newToken)
            let (_, retryResponse) = try await performRequest(retryRequest)
            guard let retryHttp = retryResponse as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            try validate(statusCode: retryHttp.statusCode)
            return
        }

        try validate(statusCode: http.statusCode)
    }

    // MARK: - Privado

    private func buildRequest(for endpoint: any Endpoint) throws -> URLRequest {
        let token: String? = endpoint.requiresAuth
            ? try? tokenInterceptor.accessToken()
            : nil
        return try requestBuilder.build(endpoint, accessToken: token)
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await NetworkMonitor.shared.assertConnected()
        do {
            return try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw NetworkError.cancelled
        } catch {
            IFLogger.error(error, context: "APIClient.performRequest")
            throw error
        }
    }

    private func retryAfterRefresh<T: Decodable>(endpoint: any Endpoint) async throws -> T {
        let newToken = try await refreshCurrentToken()
        let retryRequest = try requestBuilder.build(endpoint, accessToken: newToken)
        let (retryData, retryResponse) = try await performRequest(retryRequest)

        guard let http = retryResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        try validate(statusCode: http.statusCode)
        return try decode(retryData)
    }

    /// Ejecuta una petición sin la lógica de reintento ante 401. Lo usa internamente
    /// `refreshCurrentToken` para evitar bucles de refresco recursivos.
    private func executeRaw<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let urlRequest = try buildRequest(for: endpoint)
        let (data, response) = try await performRequest(urlRequest)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        try validate(statusCode: http.statusCode)
        return try decode(data)
    }

    private func refreshCurrentToken() async throws -> String {
        try await tokenInterceptor.refreshAccessToken { refreshToken in
            let body = RefreshTokenDTO(refreshToken: refreshToken)
            let dto: TokenResponseDTO = try await self.executeRaw(try RefreshTokenEndpoint(body: body))
            return (access: dto.accessToken, refresh: dto.refreshToken)
        }
    }

    private func validate(statusCode: Int) throws {
        switch statusCode {
        case 200...299: return
        case 401:       throw NetworkError.unauthorized
        case 400...499: throw NetworkError.requestFailed(statusCode: statusCode)
        case 500...599: throw NetworkError.serverError(statusCode: statusCode, message: nil)
        default:        throw NetworkError.requestFailed(statusCode: statusCode)
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder.investFlow.decode(T.self, from: data)
        } catch {
            let wrapped = NetworkError.decodingFailed(error.localizedDescription)
            IFLogger.error(wrapped, context: "APIClient.decode<\(T.self)>")
            throw wrapped
        }
    }
}

// MARK: - Auxiliares

extension JSONDecoder {
    static let investFlow: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    static func investFlow() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
