//
//  GetMarketNewsUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct GetMarketNewsUseCase: Sendable {

    public init() {}

    public func execute() async -> [MarketNews] {
        try? await Task.sleep(for: .milliseconds(90))
        return Self.mockNews
    }

    private static let mockNews: [MarketNews] = [
        MarketNews(
            id: "news_001",
            headline: "S&P 500 cierra en máximos históricos impulsado por tecnología",
            summary: "El índice superó los 5,200 puntos por primera vez en la historia, liderado por ganancias en Apple, Microsoft y Nvidia.",
            source: "Bloomberg",
            publishedAt: Date().addingTimeInterval(-3_600),
            relatedSymbol: "SPY"
        ),
        MarketNews(
            id: "news_002",
            headline: "Bitcoin supera los $68,000 ante expectativas de ETF de opciones",
            summary: "La aprobación de productos derivados por parte de la SEC catalizó una nueva ola de interés institucional en el activo digital.",
            source: "CoinDesk",
            publishedAt: Date().addingTimeInterval(-7_200),
            relatedSymbol: "BTC"
        ),
        MarketNews(
            id: "news_003",
            headline: "Tesla reporta entregas récord en Q1 2026 y las acciones suben 8%",
            summary: "La compañía entregó 514,000 vehículos en el primer trimestre, superando las estimaciones del mercado de 480,000 unidades.",
            source: "Reuters",
            publishedAt: Date().addingTimeInterval(-14_400),
            relatedSymbol: "TSLA"
        ),
        MarketNews(
            id: "news_004",
            headline: "Mercados latinoamericanos avanzan ante baja del dólar y datos de empleo",
            summary: "Los índices de Brasil, México y Colombia registraron ganancias superiores al 2%, favorecidos por el debilitamiento del dólar y cifras positivas de empleo en EE.UU.",
            source: "El Cronista",
            publishedAt: Date().addingTimeInterval(-21_600),
            relatedSymbol: nil
        ),
        MarketNews(
            id: "news_005",
            headline: "Apple lanza nuevas MacBook con chip M5 y el mercado reacciona positivamente",
            summary: "El nuevo procesador promete un 40% más de rendimiento en tareas de IA, reforzando la posición de Apple en el segmento de computación personal premium.",
            source: "TechCrunch",
            publishedAt: Date().addingTimeInterval(-28_800),
            relatedSymbol: "AAPL"
        )
    ]
}
