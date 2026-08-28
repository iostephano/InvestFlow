//
//  MarketNewsDetailView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct MarketNewsDetailView: View {

    let news: MarketNews
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ifNavy.ignoresSafeArea()

                // Glow de acento — arriba-derecha, refleja el lenguaje de las tarjetas
                RadialGradient(
                    colors: [Color.ifBlue.opacity(0.18), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 300
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        HStack(alignment: .center, spacing: 12) {
                            sourceIcon
                            VStack(alignment: .leading, spacing: 3) {
                                Text(news.source)
                                    .font(.ifCaption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.ifBlue)
                                Text(relativeDate)
                                    .font(.ifCaption)
                                    .foregroundStyle(.ifSecondary)
                            }
                            Spacer()
                            if let symbol = news.relatedSymbol {
                                Text(symbol)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.ifBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.ifBlue.opacity(0.12), in: Capsule())
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(Color.ifBlue.opacity(0.22), lineWidth: 0.5)
                                    }
                            }
                        }

                        Text(news.headline)
                            .font(.ifTitle)
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(news.summary)
                            .font(.ifBody)
                            .foregroundStyle(.white.opacity(0.78))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        demoDisclaimer

                        sourceButton

                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.white.opacity(0.70))
                }
            }
            .toolbarBackground(Color.ifNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subvistas

    private var sourceIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.ifBlue.opacity(0.12))
                .frame(width: 44, height: 44)
            Image(systemName: "newspaper.fill")
                .font(.system(size: 18))
                .foregroundStyle(.ifBlue)
        }
    }

    private var demoDisclaimer: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ifViolet)
                Text("Contenido demo")
                    .font(.ifCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.ifViolet)
            }
            Text("Esta noticia forma parte del contenido demo de InvestFlow. En una versión productiva, se obtendría desde un proveedor de datos financieros o una API de noticias del mercado.")
                .font(.ifSubhead)
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.ifViolet.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
                .strokeBorder(Color.ifViolet.opacity(0.22), lineWidth: 0.5)
        }
    }

    private var sourceButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .font(.system(size: 14, weight: .medium))
            Text("Ver fuente original")
                .font(.ifBody)
                .fontWeight(.semibold)
            Spacer()
            Text("Próximamente")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.ifSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .foregroundStyle(.white.opacity(0.38))
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
        }
    }

    // MARK: - Auxiliares

    private var relativeDate: String {
        let diff = Date().timeIntervalSince(news.publishedAt)
        switch diff {
        case ..<3_600:   return "Hace \(Int(diff / 60))m"
        case ..<86_400:  return "Hace \(Int(diff / 3_600))h"
        default:         return "Hace \(Int(diff / 86_400))d"
        }
    }
}
