//
//  AuthSession.swift
//  InvestFlow
//
//  Created by Stephano Portella on 24/04/2026.
//

import Foundation

public struct AuthSession: Sendable {
    public let userID:        String
    public let accessToken:   String
    public let refreshToken:  String
    public let expiresAt:     Date

    public var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-60) }

    public init(
        userID:       String,
        accessToken:  String,
        refreshToken: String,
        expiresAt:    Date
    ) {
        self.userID        = userID
        self.accessToken   = accessToken
        self.refreshToken  = refreshToken
        self.expiresAt     = expiresAt
    }
}
