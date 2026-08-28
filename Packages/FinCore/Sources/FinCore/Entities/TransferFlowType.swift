//
//  TransferFlowType.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// Dirección del flujo de transferencia iniciado por el usuario.
public enum TransferFlowType: String, Hashable, Sendable, Identifiable {
    case deposit    = "deposit"
    case withdrawal = "withdrawal"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .deposit:    return "Depositar"
        case .withdrawal: return "Retirar"
        }
    }

    public var navigationTitle: String {
        switch self {
        case .deposit:    return "Selecciona tu país"
        case .withdrawal: return "¿Desde dónde retiras?"
        }
    }
}
