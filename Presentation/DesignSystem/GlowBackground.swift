//
//  GlowBackground.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI

/// Fondo de gradiente ambiental animado para pantallas fintech premium en modo oscuro.
///
/// Canvas de cuatro capas: una base de gradiente vertical navy-a-navy (rompe el centro
/// oscuro plano), un LinearGradient azul arriba-izquierda (a prueba de "disco"), un blob
/// RadialGradient violeta abajo-derecha, y un gran bloom difuso central que llena la
/// zona media de la pantalla. `.ignoresSafeArea()` vive internamente en el ZStack para
/// que los UnitPoint mapeen a la pantalla física completa sin importar restricciones de
/// un NavigationStack o TabView padre — por eso no hace falta un `.ignoresSafeArea()`
/// externo: la vista es autocontenida.
struct GlowBackground: View {

    var primaryAccent: Color = .ifBlue
    var secondaryAccent: Color = .ifViolet

    @State private var phase = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Capa 0: base de gradiente vertical — tinte azul sutil arriba, navy
                // profundo al centro, tinte violeta abajo. Rompe la zona muerta plana sin
                // ningún punto brillante; todos los stops son oscuros.
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.04, green: 0.06, blue: 0.22), location: 0.0),
                        .init(color: Color.ifNavy,                              location: 0.50),
                        .init(color: Color(red: 0.06, green: 0.04, blue: 0.19), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Capa 1: baño azul primario — LinearGradient (a prueba de "disco").
                // endPoint extendido a (0.70, 0.72) para que el tinte azul llegue al centro.
                LinearGradient(
                    colors: [primaryAccent.opacity(0.42), .clear],
                    startPoint: UnitPoint(x: phase ? 0.05 : 0.15, y: 0.0),
                    endPoint:   UnitPoint(x: 0.70, y: 0.72)
                )
                .blur(radius: 44)

                // Capa 2: blob violeta — abajo-derecha, deriva en contra
                RadialGradient(
                    colors: [secondaryAccent.opacity(0.50), .clear],
                    center: UnitPoint(x: phase ? 0.84 : 0.78, y: phase ? 0.68 : 0.75),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.70
                )
                .blur(radius: 40)

                // Capa 3: bloom central — baño azul grande y extremadamente difuso.
                // el radio basado en la altura llena pantallas largas; blur(50) elimina
                // cualquier borde de disco, así el resultado es un campo de color ambiental
                // puro, nunca un círculo.
                RadialGradient(
                    colors: [primaryAccent.opacity(0.26), .clear],
                    center: UnitPoint(x: 0.50, y: phase ? 0.47 : 0.53),
                    startRadius: 0,
                    endRadius: geo.size.height * 0.42
                )
                .blur(radius: 50)
            }
            // ignoresSafeArea va en este ZStack — no sobre GlowBackground desde afuera.
            // Así el espacio de UnitPoint del gradiente equivale a la pantalla física
            // completa (geo.size por sí solo es el tamaño propuesto limitado por el safe
            // area, que es más chico; poner ignoresSafeArea externamente no ensancha ese
            // espacio a través de un GeometryReader, y los centros de los blobs caen en la
            // zona equivocada).
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 7.0).repeatForever(autoreverses: true),
                value: phase
            )
            .onAppear { phase = true }
        }
    }
}

// MARK: - Vistas previas

#Preview("Glow Background — Dark") {
    glowBackgroundPreviewContent()
}

#Preview("Glow Background — Glass Surfaces") {
    glowBackgroundPreviewContent()
        .preferredColorScheme(.dark)
}

private func glowBackgroundPreviewContent() -> some View {
    ZStack {
        GlowBackground().ignoresSafeArea()
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Material.regularMaterial)
                .frame(height: 120)
                .overlay {
                    Text("Hero (regularMaterial)")
                        .font(.headline).foregroundStyle(.primary)
                }
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Material.thinMaterial)
                .frame(height: 80)
                .overlay {
                    Text("Card (thinMaterial)")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Material.ultraThinMaterial)
                .frame(height: 48)
                .overlay {
                    Text("Pill (ultraThinMaterial)")
                        .font(.caption).foregroundStyle(.secondary)
                }
        }
        .padding(24)
    }
}
