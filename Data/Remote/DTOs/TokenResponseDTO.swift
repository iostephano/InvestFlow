//
//  TokenResponseDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Respuesta del endpoint POST /auth/refresh.
/// convertFromSnakeCase: access_token → accessToken.
struct TokenResponseDTO: Decodable, Sendable {
    let accessToken:  String
    let refreshToken: String

    private enum CodingKeys: CodingKey {
        case accessToken, refreshToken
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        accessToken  = try c.decode(String.self, forKey: .accessToken)
        refreshToken = try c.decode(String.self, forKey: .refreshToken)
    }
}
