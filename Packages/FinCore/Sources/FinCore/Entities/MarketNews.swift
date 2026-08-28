//
//  MarketNews.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation

public struct MarketNews: Identifiable, Sendable {
    public let id: String
    public let headline: String
    public let summary: String
    public let source: String
    public let publishedAt: Date
    public let imageURL: URL?
    public let relatedSymbol: String?

    public init(
        id: String,
        headline: String,
        summary: String,
        source: String,
        publishedAt: Date,
        imageURL: URL? = nil,
        relatedSymbol: String? = nil
    ) {
        self.id = id
        self.headline = headline
        self.summary = summary
        self.source = source
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.relatedSymbol = relatedSymbol
    }
}
