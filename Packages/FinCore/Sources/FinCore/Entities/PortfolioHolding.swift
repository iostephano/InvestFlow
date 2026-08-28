//
//  PortfolioHolding.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct PortfolioHolding: Identifiable, Sendable {
    public let id: String
    public let instrumentID: String
    public let instrumentName: String
    public let instrumentType: InstrumentType
    public let allocationPercent: Decimal   // peso objetivo, suma 100
    public let targetReturnPercent: Decimal // retorno esperado anualizado para este holding

    public init(
        id: String,
        instrumentID: String,
        instrumentName: String,
        instrumentType: InstrumentType,
        allocationPercent: Decimal,
        targetReturnPercent: Decimal
    ) {
        self.id = id
        self.instrumentID = instrumentID
        self.instrumentName = instrumentName
        self.instrumentType = instrumentType
        self.allocationPercent = allocationPercent
        self.targetReturnPercent = targetReturnPercent
    }
}
