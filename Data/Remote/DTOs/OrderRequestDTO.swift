//
//  OrderRequestDTO.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Cuerpo del request para crear una nueva orden.
/// Cantidades y precios se envían como String para preservar precisión decimal.
/// El encoder usa convertToSnakeCase: instrumentId → instrument_id.
struct OrderRequestDTO: Encodable, Sendable {
    let instrumentId: String
    let side: String          // OrderSide.rawValue  e.g. "BUY"
    let type: String          // OrderType.rawValue  e.g. "MARKET"
    let quantity: String      // Decimal.description e.g. "10"
    let limitPrice: String?
    let stopPrice: String?
    let timeInForce: String   // TimeInForce.rawValue e.g. "DAY"
}
