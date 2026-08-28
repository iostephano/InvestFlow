//
//  IFElevation.swift
//  InvestFlow
//
//  Created by Stephano Portella on 08/05/2026.
//

import SwiftUI

/// Sistema de sombras semánticas de InvestFlow.
///
/// Las sombras expresan jerarquía de profundidad, no decoración. Elegir el nivel
/// que visualmente eleva la superficie por encima de su fondo inmediato —
/// ni más, ni menos.
///
/// ### Materiales + sombras
/// Los materiales de vidrio ya implican profundidad vía blur y vibrancy. Al combinarlos,
/// reducir la fuerza de la sombra: preferir `.sm` sobre una superficie `.glass` y `.md` sobre una `.floatingGlass`.
/// Nunca usar `.lg` sobre una tarjeta de vidrio — esa combinación compite visualmente.
struct IFShadow: Sendable {

    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Sin sombra. Usar para superficies embebidas dentro de contenedores ya elevados.
    static let none = IFShadow(color: .clear, radius: 0, x: 0, y: 0)

    /// Radio 4 pt, y +2 — elevación apenas presente para tarjetas inline sobre fondos planos.
    static let sm = IFShadow(
        color: .black.opacity(0.06),
        radius: 4, x: 0, y: 2
    )

    /// Radio 12 pt, y +4 — efecto flotante claro para paneles y toolbars.
    static let md = IFShadow(
        color: .black.opacity(0.10),
        radius: 12, x: 0, y: 4
    )

    /// Radio 24 pt, y +8 — separación fuerte para drawers y overlays completos.
    static let lg = IFShadow(
        color: .black.opacity(0.18),
        radius: 24, x: 0, y: 8
    )
}

// MARK: - Extensión de View

extension View {
    /// Aplica una sombra semántica de InvestFlow. Se salta la pasada de render cuando la sombra es `.none`.
    @ViewBuilder
    func ifShadow(_ shadow: IFShadow) -> some View {
        if shadow.radius > 0 {
            self.shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
        } else {
            self
        }
    }
}
