//
//  IFCardGlow.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

/// Glow ambiental de doble capa para superficies de nivel tarjeta.
///
/// Aplica dos sombras apiladas para simular una fuente de luz emisiva debajo de la tarjeta:
/// - Un halo exterior amplio (radio completo, menor opacidad) crea el bloom difuso.
/// - Una capa interior más ajustada (55 % del radio, multiplicador de opacidad 45 %) agrega
///   un brillo de núcleo nítido.
///
/// Este enfoque de dos capas refleja `IFGlowModifier` — que apunta a elementos de primer
/// plano — pero está ajustado a la mayor superficie y a la dirección de luz descendente de
/// los contenedores tipo tarjeta.
///
/// ## Guía de intensidad
/// | Contexto                    | opacity | radius |
/// |-----------------------------|---------|--------|
/// | Hero card (foco primario)   | 0.30    | 30     |
/// | Tarjetas promo / temáticas  | 0.26    | 26     |
/// | Paneles secundarios         | 0.16    | 22     |
/// | Neutro / muy sutil          | 0.10    | 18     |
extension View {

    /// Agrega un glow ambiental premium debajo de una superficie de tarjeta.
    /// - Parameters:
    ///   - color: Color del glow. Usar tokens de marca: `.ifBlue`, `.ifGreen`, `.ifViolet`.
    ///   - radius: Radio del halo exterior en puntos. Default 28.
    ///   - opacity: Opacidad base del halo exterior. La capa interior escala automáticamente. Default 0.26.
    func cardGlow(
        color: Color,
        radius: CGFloat = 28,
        opacity: Double = 0.26
    ) -> some View {
        self
            // Halo difuso exterior — bloom amplio, anclado debajo de la tarjeta
            .shadow(color: color.opacity(opacity),        radius: radius,        x: 0, y: 10)
            // Bloom de núcleo interior — más ajustado, más brillante, cerca del borde de la tarjeta
            .shadow(color: color.opacity(opacity * 0.45), radius: radius * 0.55, x: 0, y: 4)
    }
}
