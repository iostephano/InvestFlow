//
//  AuthEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - POST /auth/login

struct LoginEndpoint: Endpoint {
    var path:         String     { "/auth/login" }
    var method:       HTTPMethod { .post }
    var requiresAuth: Bool       { false }
    let bodyData:     Data?

    init(body: LoginRequestDTO) throws {
        bodyData = try JSONEncoder.investFlow().encode(body)
    }
}

// MARK: - POST /auth/refresh

struct RefreshTokenEndpoint: Endpoint {
    var path:         String     { "/auth/refresh" }
    var method:       HTTPMethod { .post }
    var requiresAuth: Bool       { false }
    let bodyData:     Data?

    init(body: RefreshTokenDTO) throws {
        bodyData = try JSONEncoder.investFlow().encode(body)
    }
}

// MARK: - POST /auth/logout

struct LogoutEndpoint: Endpoint {
    var path:   String     { "/auth/logout" }
    var method: HTTPMethod { .post }
}
