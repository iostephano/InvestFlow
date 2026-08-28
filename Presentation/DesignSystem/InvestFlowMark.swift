//
//  InvestFlowMark.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI

/// La marca de InvestFlow: una flecha ascendente sobre un squircle navy, en eco
/// del icono de la app. Única fuente de verdad para el logo dentro de la app, así el
/// splash, el login y el drawer quedan visualmente idénticos al AppIcon.
struct InvestFlowMark: View {

    var size: CGFloat = 64
    /// Agrega un bloom verde ambiental detrás de la flecha (se usa en splash/login).
    var glow: Bool = false

    private var corner: CGFloat { size * 0.27 }

    var body: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.16, blue: 0.31),
                        Color(red: 0.04, green: 0.09, blue: 0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                // Borde especular — de 3 stops, consistente con el design system.
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.34), location: 0.0),
                                .init(color: .white.opacity(0.10), location: 0.45),
                                .init(color: .white.opacity(0.02), location: 1.0),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
            .overlay { arrow }
            .frame(width: size, height: size)
    }

    @ViewBuilder
    private var arrow: some View {
        let image = Image(systemName: "arrow.up.right")
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(Color.ifGreen)

        if glow {
            image.ifGlow(color: .ifGreen, radius: size * 0.16)
        } else {
            image
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 32) {
            InvestFlowMark(size: 96, glow: true)
            InvestFlowMark(size: 64, glow: true)
            InvestFlowMark(size: 44)
        }
    }
}
