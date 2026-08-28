//
//  IFGlow.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

/// Efecto bloom/glow vía sombras apiladas — bloom interior ajustado sobre un halo difuso amplio.
///
/// Este enfoque de dos capas refleja el bloom físico de una fuente de luz emisiva.
/// Se adapta al esquema de color: intensidad completa en modo oscuro, 40% en modo claro
/// para que el glow siga siendo sobrio sin saturar los fondos claros.
///
/// No es para fondos de tarjeta — usar `GlowBackground` para fondos ambientales y
/// `.ifSurface()` para superficies de tarjeta tintadas. Este modifier es para elementos
/// de primer plano: texto de precios, iconos, símbolos, badges.
struct IFGlowModifier: ViewModifier {

    let color: Color
    let radius: CGFloat

    @Environment(\.colorScheme) private var colorScheme
    private var intensity: Double { colorScheme == .dark ? 1.0 : 0.40 }

    func body(content: Content) -> some View {
        content
            // Bloom interior — ajustado, saturado
            .shadow(color: color.opacity(0.70 * intensity), radius: radius * 0.5, x: 0, y: 0)
            // Halo exterior — amplio, difuso
            .shadow(color: color.opacity(0.35 * intensity), radius: radius,       x: 0, y: 0)
    }
}

extension View {

    /// Aplica un glow de bloom alrededor de la vista.
    /// - Parameters:
    ///   - color: Color del glow. Usar colores de marca/semánticos: `.ifBlue`, `.ifGreen`, `.ifRed`.
    ///   - radius: Radio del halo exterior en puntos. Default 8.
    func ifGlow(color: Color, radius: CGFloat = 8) -> some View {
        modifier(IFGlowModifier(color: color, radius: radius))
    }
}
