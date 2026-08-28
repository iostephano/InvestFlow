//
//  NewsCard.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct NewsCard: View {

    let news: MarketNews

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                sourceIcon
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(news.headline)
                        .font(.ifBody)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Text(news.source)
                            .font(.ifCaption)
                            .foregroundStyle(.ifSecondary)

                        Text("·")
                            .foregroundStyle(.ifTertiary)

                        Text(relativeDate)
                            .font(.ifCaption)
                            .foregroundStyle(.ifSecondary)

                        if let symbol = news.relatedSymbol {
                            Text(symbol)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.ifBlue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.ifBlue.opacity(0.1), in: Capsule())
                        }
                    }
                }
            }

            Text(news.summary)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ifSurface(.glass, radius: IFRadius.md, specularBorder: true)
    }

    // MARK: - Auxiliares

    private var sourceIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.ifBlue.opacity(0.1))
                .frame(width: 36, height: 36)
            Image(systemName: "newspaper.fill")
                .font(.system(size: 16))
                .foregroundStyle(.ifBlue)
        }
    }

    private var relativeDate: String {
        let diff = Date().timeIntervalSince(news.publishedAt)
        switch diff {
        case ..<3_600:   return "Hace \(Int(diff / 60))m"
        case ..<86_400:  return "Hace \(Int(diff / 3_600))h"
        default:         return "Hace \(Int(diff / 86_400))d"
        }
    }
}
