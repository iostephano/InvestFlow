//
//  GetPortfolioPerformanceUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetPortfolioPerformanceUseCase: Sendable {

    public init() {}

    public func execute(portfolioID: String, period: PerformancePeriod) -> PortfolioPerformance {
        let points   = makeDataPoints(portfolioID: portfolioID, period: period)
        let total    = points.last?.returnPercent ?? .zero
        let annual   = annualizedReturn(totalPercent: total, years: period.years)
        let drawdown = maxDrawdown(points)
        return PortfolioPerformance(
            period:                   period,
            totalReturnPercent:       round2(total),
            annualizedReturnPercent:  round2(annual),
            maxDrawdownPercent:       round2(drawdown),
            dataPoints:               points
        )
    }

    // MARK: - Generación de datos

    private func makeDataPoints(portfolioID: String, period: PerformancePeriod) -> [PerformanceDataPoint] {
        let base = baseBasisPoints(portfolioID)   // monthly base return in basis points
        let vol  = volatilityBasisPoints(portfolioID)
        var seed = fnvSeed(portfolioID + period.rawValue)
        var cum  = Decimal.zero
        let now  = Date()
        return (0 ..< period.monthCount).map { i in
            let monthsBack = period.monthCount - 1 - i
            let date = Calendar.current.date(byAdding: .month, value: -monthsBack, to: now) ?? now
            let noise = lcgNext(&seed, range: vol)  // in basis points
            cum += Decimal(base + noise) / 10_000   // convert bp → fraction, accumulate as %
            return PerformanceDataPoint(
                id:            "\(portfolioID)-\(i)",
                date:          date,
                returnPercent: round2(cum * 100)    // se guarda como %
            )
        }
    }

    // MARK: - Configuración de portafolio

    /// Retorno base mensual en puntos básicos (1 pb = 0.01%).
    private func baseBasisPoints(_ id: String) -> Int {
        switch id {
        case "sp_income": return 42   // ~5% / año
        case "sp_growth": return 75   // ~9% / año
        case "sp_latam":  return 110  // ~13% / año
        default:          return 60
        }
    }

    /// Amplitud del ruido en puntos básicos por mes.
    private func volatilityBasisPoints(_ id: String) -> Int {
        switch id {
        case "sp_income": return 80
        case "sp_growth": return 160
        case "sp_latam":  return 250
        default:          return 120
        }
    }

    // MARK: - Cálculo numérico

    private func annualizedReturn(totalPercent: Decimal, years: Int) -> Decimal {
        guard years > 0, totalPercent > -100 else { return totalPercent }
        let t = Double(truncating: totalPercent as NSDecimalNumber)
        let a = (pow(1.0 + t / 100.0, 1.0 / Double(years)) - 1.0) * 100.0
        return Decimal(a)
    }

    private func maxDrawdown(_ points: [PerformanceDataPoint]) -> Decimal {
        var peak = Decimal.zero
        var dd   = Decimal.zero
        for p in points {
            if p.returnPercent > peak { peak = p.returnPercent }
            let cur = peak - p.returnPercent
            if cur > dd { dd = cur }
        }
        return dd
    }

    private func round2(_ v: Decimal) -> Decimal {
        var x = v, r = Decimal()
        NSDecimalRound(&r, &x, 2, .plain)
        return r
    }

    // MARK: - PRNG determinista

    private func fnvSeed(_ s: String) -> UInt64 {
        s.utf8.reduce(14_695_981_039_346_656_037 as UInt64) {
            ($0 ^ UInt64($1)) &* 1_099_511_628_211
        }
    }

    /// Devuelve un valor de ruido en el rango `[-amplitude, amplitude]` puntos básicos.
    private func lcgNext(_ seed: inout UInt64, range: Int) -> Int {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let raw = Int(bitPattern: UInt(seed >> 33))  // con signo
        return raw % (range + 1)
    }
}
