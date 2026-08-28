//
//  RefreshTokenDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Cuerpo del request para renovar el access token con el refresh token.
struct RefreshTokenDTO: Encodable, Sendable {
    let refreshToken: String
}
