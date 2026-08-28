//
//  PromoCardView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI

struct PromoCardView: View {

    let card: HomeViewModel.PromoCard

    var body: some View {
        ZStack {
            // Capa 1: blur de vidrio — captura el ambiente de GlowBackground
            RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                .fill(Material.regularMaterial)

            // Capa 2: overlay de profundidad oscuro — unificado, asegura el contraste del texto en ambos temas
            RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.07, green: 0.09, blue: 0.22).opacity(0.82), location: 0.0),
                            .init(color: Color(red: 0.03, green: 0.04, blue: 0.14).opacity(0.96), location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Capa 3: glow de acento del tema — la esquina superior-derecha actúa como fuente de luz de color
            RadialGradient(
                colors: [themeColor.opacity(0.54), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 130
            )
            .allowsHitTesting(false)

            // Capa 4: ilustración PNG custom — va por encima del glow, por debajo del HStack de texto.
            Image(illustrationName)
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .opacity(0.95)
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                Text(card.title)
                    .font(.ifHeadline)
                    .foregroundStyle(.white)
                    // La sombra del texto agrega legibilidad sobre el vidrio + gradiente
                    .shadow(color: .black.opacity(0.40), radius: 5, x: 0, y: 2)
                    .lineLimit(2)
                Text(card.subtitle)
                    .font(.ifSubhead)
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous))
        // Borde especular — iridiscente animado (mismo modifier que HeroCard)
        .premiumSpecularBorder(cornerRadius: IFRadius.md, lineWidth: 1.0)
        // Badge — arriba-izquierda, puramente decorativo
        .overlay(alignment: .topLeading) {
            Text(badgeLabel)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .kerning(0.4)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(themeColor.opacity(0.90), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
                }
                .padding(.leading, 12)
                .padding(.top, 10)
        }
    }

    // MARK: - Auxiliares de tema

    private var themeColor: Color {
        switch card.theme {
        case .blue:   return .ifBlue
        case .green:  return .ifGreen
        case .purple: return .ifViolet
        }
    }

    private var illustrationName: String {
        switch card.theme {
        case .blue:   return "promo_diversifica"
        case .green:  return "promo_crypto"
        case .purple: return "promo_inversion"
        }
    }

    private var badgeLabel: String {
        switch card.theme {
        case .blue:   return "NUEVO"
        case .green:  return "POPULAR"
        case .purple: return "RECOMENDADO"
        }
    }
}

// MARK: - Vista previa

#Preview("PromoCards — Dark") {
    ZStack {
        GlowBackground().ignoresSafeArea()
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(HomeViewModel.PromoCard.defaultCards) { card in
                    PromoCardView(card: card)
                        .frame(width: 300, height: 150)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 200)
    }
    .preferredColorScheme(.dark)
}
