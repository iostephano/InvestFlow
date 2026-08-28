//
//  GetPortfolioHoldingsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetPortfolioHoldingsUseCase: Sendable {

    public init() {}

    public func execute(portfolioID: String) -> [PortfolioHolding] {
        switch portfolioID {
        case "sp_growth": return Self.growth
        case "sp_income": return Self.income
        case "sp_latam":  return Self.latam
        default:          return Self.growth
        }
    }

    // MARK: - Catálogo de holdings

    private static let growth: [PortfolioHolding] = [
        PortfolioHolding(id: "g_qqq",  instrumentID: "QQQ",  instrumentName: "Invesco QQQ Trust",    instrumentType: .etf,   allocationPercent: 40, targetReturnPercent: 14),
        PortfolioHolding(id: "g_spy",  instrumentID: "SPY",  instrumentName: "SPDR S&P 500 ETF",     instrumentType: .etf,   allocationPercent: 30, targetReturnPercent: 12),
        PortfolioHolding(id: "g_aapl", instrumentID: "AAPL", instrumentName: "Apple Inc.",           instrumentType: .stock, allocationPercent: 20, targetReturnPercent: 13),
        PortfolioHolding(id: "g_tsla", instrumentID: "TSLA", instrumentName: "Tesla Inc.",           instrumentType: .stock, allocationPercent: 10, targetReturnPercent: 18)
    ]

    private static let income: [PortfolioHolding] = [
        PortfolioHolding(id: "i_spy",  instrumentID: "SPY",  instrumentName: "SPDR S&P 500 ETF",     instrumentType: .etf,   allocationPercent: 50, targetReturnPercent: 10),
        PortfolioHolding(id: "i_qqq",  instrumentID: "QQQ",  instrumentName: "Invesco QQQ Trust",    instrumentType: .etf,   allocationPercent: 30, targetReturnPercent: 9),
        PortfolioHolding(id: "i_aapl", instrumentID: "AAPL", instrumentName: "Apple Inc.",           instrumentType: .stock, allocationPercent: 20, targetReturnPercent: 7)
    ]

    private static let latam: [PortfolioHolding] = [
        PortfolioHolding(id: "l_qqq",  instrumentID: "QQQ",  instrumentName: "Invesco QQQ Trust",    instrumentType: .etf,   allocationPercent: 30, targetReturnPercent: 16),
        PortfolioHolding(id: "l_btc",  instrumentID: "BTC",  instrumentName: "Bitcoin",              instrumentType: .crypto, allocationPercent: 25, targetReturnPercent: 30),
        PortfolioHolding(id: "l_eth",  instrumentID: "ETH",  instrumentName: "Ethereum",             instrumentType: .crypto, allocationPercent: 25, targetReturnPercent: 25),
        PortfolioHolding(id: "l_tsla", instrumentID: "TSLA", instrumentName: "Tesla Inc.",           instrumentType: .stock, allocationPercent: 20, targetReturnPercent: 20)
    ]
}
