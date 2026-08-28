//
//  LoginRequestDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Cuerpo del request para iniciar sesión.
struct LoginRequestDTO: Encodable, Sendable {
    let email: String
    let password: String
}
