//
//  LoginResponseDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation

/// Respuesta del endpoint POST /auth/login.
/// convertFromSnakeCase: user_id → userId, expires_at → expiresAt.
struct LoginResponseDTO: Decodable, Sendable {
    let accessToken:  String
    let refreshToken: String
    let expiresAt:    Date
    let userId:       String

    private enum CodingKeys: CodingKey {
        case accessToken, refreshToken, expiresAt, userId
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        accessToken  = try c.decode(String.self, forKey: .accessToken)
        refreshToken = try c.decode(String.self, forKey: .refreshToken)
        expiresAt    = try c.decode(Date.self,   forKey: .expiresAt)
        userId       = try c.decode(String.self, forKey: .userId)
    }
}
