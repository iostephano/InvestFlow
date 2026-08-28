//
//  Instrument.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Tipo de activo que InvestFlow soporta.
/// InvestFlow ofrece acciones, ETFs, crypto y portafolios administrados.
public enum InstrumentType: String, Codable, Sendable {
    case stock      = "STOCK"
    case etf        = "ETF"
    case crypto     = "CRYPTO"
    case portfolio  = "PORTFOLIO"  // Portafolios temáticos de InvestFlow
}

/// Moneda de cotización del instrumento.
public enum Currency: String, Codable, Sendable {
    case usd = "USD"
    case pen = "PEN"   // Sol peruano
    case ars = "ARS"   // Peso argentino
    case mxn = "MXN"   // Peso mexicano
    case brl = "BRL"   // Real brasileño
}

/// Entidad central: representa cualquier activo invertible en InvestFlow.
/// Inmutable por diseño — los precios se actualizan vía Quote, no aquí.
public struct Instrument: Identifiable, Hashable, Sendable {
    public let id: String           // Ticker: "AAPL", "BTC", "SPY"
    public let name: String         // "Apple Inc.", "Bitcoin"
    public let type: InstrumentType
    public let currency: Currency
    public let logoURL: URL?
    public let exchange: String     // "NASDAQ", "NYSE", "CRYPTO"
    public let isActive: Bool       // Si está disponible para operar en InvestFlow
    
    public init(
        id: String,
        name: String,
        type: InstrumentType,
        currency: Currency,
        logoURL: URL? = nil,
        exchange: String,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.currency = currency
        self.logoURL = logoURL
        self.exchange = exchange
        self.isActive = isActive
    }
}
