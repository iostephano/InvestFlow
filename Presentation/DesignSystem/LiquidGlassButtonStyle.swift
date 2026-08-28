//
//  LiquidGlassButtonStyle.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI

/// Estilo de botón relleno para CTAs primarios de Liquid Glass.
///
/// Usa un relleno de tinte sólido (no vidrio — los CTAs primarios deben ser opacos para la
/// legibilidad), un borde superior especular y una sombra de glow ambiental que se desvanece
/// al presionar. La interacción de press sigue el mismo modelo de spring asimétrico que
/// `IFCardStyle`: press sobreamortiguado (sin oscilación) + release subamortiguado (un único pop de sobrepaso).
///
/// El glow se desvanece a cero al presionar: el botón "desciende" físicamente alejándose de
/// la fuente de luz cenital implícita, consistente con el fade de sombra de `IFCardStyle`.
struct LiquidGlassButtonStyle: ButtonStyle {

    var tint: Color

    init(tint: Color = .ifBlue) {
        self.tint = tint
    }

    func makeBody(configuration: Configuration) -> some View {
        LiquidGlassButtonContent(configuration: configuration, tint: tint)
    }
}

// MARK: - Vista de contenido

private struct LiquidGlassButtonContent: View {

    let configuration: ButtonStyleConfiguration
    let tint: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1.0

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
    }

    var body: some View {
        configuration.label
            .background {
                shape
                    .fill(tint)
                    // Borde superior especular: fuente de luz por encima del CTA
                    .overlay(alignment: .top) {
                        shape.strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.32), .clear],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 0.75
                        )
                    }
            }
            // El glow ambiental se desvanece al presionar — el botón se hunde alejándose de la fuente de luz
            .shadow(
                color: tint.opacity(configuration.isPressed ? 0.0 : 0.35),
                radius: 14,
                x: 0,
                y: 5
            )
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .opacity(configuration.isPressed && reduceMotion ? 0.88 : 1.0)
            .onChange(of: configuration.isPressed) { _, pressed in
                withAnimation(pressed ? IFMotion.cardPress : IFMotion.cardRelease) {
                    scale = pressed ? 0.97 : 1.0
                }
            }
    }
}

// MARK: - Extensión

extension ButtonStyle where Self == LiquidGlassButtonStyle {

    /// CTA primario — relleno ifBlue con glow ambiental.
    static var liquidGlass: LiquidGlassButtonStyle { .init() }

    /// CTA primario con tinte personalizado.
    static func liquidGlass(tint: Color) -> LiquidGlassButtonStyle {
        LiquidGlassButtonStyle(tint: tint)
    }
}

// MARK: - Vista previa

#Preview("LiquidGlassButtonStyle — Dark") {
    liquidGlassButtonPreview()
        .preferredColorScheme(.dark)
}

#Preview("LiquidGlassButtonStyle — Light") {
    liquidGlassButtonPreview()
}

private func liquidGlassButtonPreview() -> some View {
    ZStack {
        GlowBackground().ignoresSafeArea()
        VStack(spacing: 16) {
            cta("Depositar ahora", tint: .ifBlue)
            cta("Invertir", tint: Color(red: 0.52, green: 0.18, blue: 0.96))
            cta("Comprar", tint: .ifGreen)
            cta("Vender", tint: .ifRed)
        }
        .padding(24)
    }
}

private func cta(_ title: String, tint: Color) -> some View {
    Button(title) {}
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .buttonStyle(.liquidGlass(tint: tint))
}
