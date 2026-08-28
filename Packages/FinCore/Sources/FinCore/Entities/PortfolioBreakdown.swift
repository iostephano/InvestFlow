//
//  PortfolioBreakdown.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct AssetAllocation: Identifiable, Sendable {
    public let id: String       // InstrumentType.rawValue
    public let label: String
    public let value: Decimal
    public let percent: Decimal

    public init(id: String, label: String, value: Decimal, percent: Decimal) {
        self.id = id
        self.label = label
        self.value = value
        self.percent = percent
    }
}

public struct PortfolioBreakdown: Sendable {
    public let totalValue: Decimal
    public let cashValue: Decimal
    public let cashPercent: Decimal
    public let investedValue: Decimal
    public let investedPercent: Decimal
    public let allocations: [AssetAllocation]   // per InstrumentType, desc by value

    public init(
        totalValue: Decimal,
        cashValue: Decimal,
        cashPercent: Decimal,
        investedValue: Decimal,
        investedPercent: Decimal,
        allocations: [AssetAllocation]
    ) {
        self.totalValue = totalValue
        self.cashValue = cashValue
        self.cashPercent = cashPercent
        self.investedValue = investedValue
        self.investedPercent = investedPercent
        self.allocations = allocations
    }

    public static let empty = PortfolioBreakdown(
        totalValue: .zero, cashValue: .zero, cashPercent: .zero,
        investedValue: .zero, investedPercent: .zero, allocations: []
    )
}
