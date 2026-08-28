//
//  PortfolioPerformance.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct PerformanceDataPoint: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let returnPercent: Decimal  // retorno acumulado desde el inicio del período (ej. 14.5 = +14.5%)

    public init(id: String, date: Date, returnPercent: Decimal) {
        self.id = id
        self.date = date
        self.returnPercent = returnPercent
    }
}

public struct PortfolioPerformance: Sendable {
    public let period: PerformancePeriod
    public let totalReturnPercent: Decimal
    public let annualizedReturnPercent: Decimal
    public let maxDrawdownPercent: Decimal
    public let dataPoints: [PerformanceDataPoint]

    public var isProfit: Bool { totalReturnPercent >= .zero }

    public init(
        period: PerformancePeriod,
        totalReturnPercent: Decimal,
        annualizedReturnPercent: Decimal,
        maxDrawdownPercent: Decimal,
        dataPoints: [PerformanceDataPoint]
    ) {
        self.period = period
        self.totalReturnPercent = totalReturnPercent
        self.annualizedReturnPercent = annualizedReturnPercent
        self.maxDrawdownPercent = maxDrawdownPercent
        self.dataPoints = dataPoints
    }
}
