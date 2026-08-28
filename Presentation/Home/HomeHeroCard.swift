//
//  HomeHeroCard.swift
//  InvestFlow
//
//  Created by Stephano Portella on 09/05/2026.
//

import SwiftUI
import FinUI

// MARK: - HomeHeroCard

struct HomeHeroCard: View {

    let amount: Decimal
    let onTap: () -> Void

    @State private var isAmountHidden = false
    private let violet = Color.ifViolet

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 6) {
                            Text("Poder adquisitivo")
                                .font(.ifCaption)
                                .tracking(0.6)
                                .foregroundStyle(.white.opacity(0.55))

                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    isAmountHidden.toggle()
                                }
                            } label: {
                                Image(systemName: isAmountHidden ? "eye" : "eye.slash")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.40))
                                    .frame(width: 20, height: 14)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .buttonStyle(.plain)
                        }

                        Text(isAmountHidden ? "•••••• $" : formattedAmount)
                            .font(.ifPriceLarge)
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .ifGlow(color: .ifBlue, radius: 12)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isAmountHidden)
                    }

                }

                // Separador — con inset, sutil
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .padding(.horizontal, 4)
                    .padding(.top, 16)
                    .padding(.bottom, 0)

                HStack(spacing: 5) {
                    Text("Ver portafolio")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.ifBlue, Color.ifBlue.opacity(0.78)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // Borde superior especular — fuente de luz implícita por encima del CTA
                        .overlay(alignment: .top) {
                            Capsule(style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.38), .white.opacity(0.06), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    ),
                                    lineWidth: 0.5
                                )
                        }
                }
                .shadow(color: Color.ifBlue.opacity(0.42), radius: 12, x: 0, y: 5)
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Padding asimétrico: arriba respira más que abajo (el CTA tiene padding interno)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    // Capa 1: base de blur de vidrio
                    RoundedRectangle(cornerRadius: IFRadius.lg, style: .continuous)
                        .fill(Material.regularMaterial)

                    // Capa 2: gradiente de profundidad oscuro — más profundo y opaco que antes
                    RoundedRectangle(cornerRadius: IFRadius.lg, style: .continuous)
                        .fill(LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.18, green: 0.22, blue: 0.44).opacity(0.78), location: 0),
                                .init(color: Color(red: 0.07, green: 0.08, blue: 0.22).opacity(0.92), location: 1),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))

                    // Capa 3: glow cyan — anclado a la esquina superior-izquierda, sin hack de frame/offset
                    RadialGradient(
                        colors: [Color.ifBlue.opacity(0.36), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 150
                    )
                    .allowsHitTesting(false)

                    // Capa 4: glow violeta — anclado abajo-derecha, recortado de forma natural
                    RadialGradient(
                        colors: [violet.opacity(0.28), .clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 120
                    )
                    .allowsHitTesting(false)

                    // Capa 5: ilustración decorativa — recortada por el clipShape existente de abajo.
                    // Va por encima de todos los gradientes pero por debajo del VStack de contenido, así el texto/CTA siempre gana.
                    Image("hero_portfolio")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 160)
                        .opacity(0.95)
                        .offset(x: 8, y: 8)
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: IFRadius.lg, style: .continuous))
            }
            // Borde especular — borde iridiscente animado
            .premiumSpecularBorder(cornerRadius: IFRadius.lg, lineWidth: 1.0)
        }
        .buttonStyle(.ifCard(shadow: .md))
        // Glow ambiental dual — halo azul amplio + bloom violeta secundario ajustado
        .shadow(color: Color.ifBlue.opacity(0.30), radius: 30, x: 0, y: 10)
        .shadow(color: violet.opacity(0.16), radius: 22, x: 4, y: 14)
    }

    // MARK: - Auxiliares

    private static let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    private var formattedAmount: String {
        Self.amountFormatter.string(from: amount as NSDecimalNumber) ?? "-"
    }
}

// MARK: - Vistas previas

#Preview("Hero Card — Dark") {
    ZStack {
        GlowBackground().ignoresSafeArea()
        HomeHeroCard(amount: 5240.00, onTap: {})
            .padding(.horizontal, 20)
            .padding(.top, 60)
    }
    .preferredColorScheme(.dark)
}

#Preview("Hero Card — Large Amount") {
    ZStack {
        GlowBackground().ignoresSafeArea()
        HomeHeroCard(amount: 128_450.75, onTap: {})
            .padding(.horizontal, 20)
            .padding(.top, 60)
    }
    .preferredColorScheme(.dark)
}

#Preview("Hero Card — Zero") {
    ZStack {
        GlowBackground().ignoresSafeArea()
        HomeHeroCard(amount: 0, onTap: {})
            .padding(.horizontal, 20)
            .padding(.top, 60)
    }
    .preferredColorScheme(.dark)
}
