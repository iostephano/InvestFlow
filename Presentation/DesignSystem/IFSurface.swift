//
//  IFSurface.swift
//  InvestFlow
//
//  Created by Stephano Portella on 08/05/2026.
//

import SwiftUI
import FinUI

// MARK: - Niveles de superficie semánticos

/// Jerarquía de superficies de material semánticas de InvestFlow.
///
/// Elegir el nivel de superficie por **lo que la superficie hace en la UI**, no por cómo debería verse.
/// La apariencia visual (profundidad de blur, vibrancy, opacidad) se deriva automáticamente.
///
/// ## Regla de rendimiento
/// Cada superficie de vidrio crea una **capa de compositor de GPU con un filtro de blur**.
/// Limitar las superficies de vidrio simultáneas por viewport. Si hay 10+ tarjetas de vidrio
/// visibles al mismo tiempo (lista de scroll rápido), el presupuesto de frames colapsa. Ahí usar `.opaque`.
///
/// ## Regla de datos financieros
/// Nunca aplicar `.glass`, `.floatingGlass` ni `.overlay` a superficies que muestran:
/// precios, balances, valores de P&L, totales de órdenes, o cualquier confirmación transaccional.
/// `.opaque` es obligatorio para todas las superficies transaccionales — la legibilidad no se negocia.
enum IFSurface {

    /// Totalmente opaco — color adaptativo del sistema `ifCard`. Sin blur.
    /// **Obligatorio** para: precios, balances, posiciones, formularios de orden, CTAs, estados de error/éxito.
    case opaque

    /// `thinMaterial` — blur ligero, alta visibilidad del contenido detrás de la superficie.
    /// Para tarjetas de contenido decorativo: noticias, insights, superficies promocionales.
    case glass

    /// `regularMaterial` — blur estándar, separación visual clara del contenido de fondo.
    /// Para paneles flotantes que deben quedar claramente por encima del contenido de scroll: drawers, toolbars fijas.
    case floatingGlass

    /// `ultraThinMaterial` — blur mínimo, máxima visibilidad del contenido.
    /// Para controles que flotan sobre el contenido sin taparlo: pills de categoría, chips de filtro.
    case overlay

    /// `thickMaterial` — blur casi opaco, fuerte separación de capas.
    /// Para bottom sheets, modales y popovers que requieren una distinción fuerte del fondo.
    case elevated

    // MARK: - Resolución de material

    /// Devuelve `AnyShapeStyle` para este nivel de superficie.
    /// `@MainActor` porque `.opaque` accede a `Color.ifCard`, que envuelve `UIColor`
    /// (los colores adaptativos de UIColor requieren resolución en el hilo principal en iOS).
    @MainActor
    var backgroundStyle: AnyShapeStyle {
        switch self {
        case .opaque:        return AnyShapeStyle(Color.ifCard)
        case .glass:         return AnyShapeStyle(Material.thinMaterial)
        case .floatingGlass: return AnyShapeStyle(Material.regularMaterial)
        case .overlay:       return AnyShapeStyle(Material.ultraThinMaterial)
        case .elevated:      return AnyShapeStyle(Material.thickMaterial)
        }
    }

    // MARK: - Sombra por defecto por nivel

    /// Sombra por defecto semántica para esta superficie.
    /// Usar `ifSurface(_:shadow:)` para sobrescribir cuando el contexto visual de la superficie
    /// difiere del default (p. ej., un panel flotante que ya está dentro de un contenedor elevado).
    var defaultShadow: IFShadow {
        switch self {
        case .opaque:        return .sm
        case .glass:         return .sm
        case .floatingGlass: return .md
        case .overlay:       return .none
        case .elevated:      return .lg
        }
    }
}

// MARK: - ViewModifier

/// Aplica una superficie semántica de InvestFlow (material + forma + sombra + borde especular opcional)
/// a cualquier vista de SwiftUI.
///
/// Preferir la extensión de View `.ifSurface()` antes que usar este modifier directamente.
struct IFSurfaceModifier: ViewModifier {

    let surface: IFSurface
    let radius: CGFloat
    let shadow: IFShadow
    /// Agrega un trazo de gradiente blanco de arriba-izquierda → abajo-derecha (0.5 pt).
    /// Simula el destello de una fuente de luz sobre el vidrio — el efecto especular de Liquid Glass.
    /// Usar solo en superficies `.glass` y `.floatingGlass`. Nunca en `.opaque` ni en datos financieros.
    let specularBorder: Bool

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background(surface.backgroundStyle, in: shape)
            .overlay {
                if specularBorder {
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                }
            }
            .ifShadow(shadow)
    }
}

// MARK: - Extensión de View

extension View {

    /// Aplica una superficie semántica de InvestFlow: material + forma de esquina continua + sombra.
    ///
    /// - Parameters:
    ///   - surface: Nivel de superficie semántico. Determina material, opacidad y sombra por defecto.
    ///   - radius: Radio de esquina en puntos. Usar tokens `IFRadius`.
    ///   - shadow: Nivel de sombra. Por defecto `surface.defaultShadow`. Sobrescribir cuando la
    ///             superficie vive dentro de un contenedor ya elevado.
    ///   - specularBorder: Agrega un destello sutil en el borde del vidrio. Solo para `.glass` / `.floatingGlass`.
    func ifSurface(
        _ surface: IFSurface,
        radius: CGFloat = IFRadius.md,
        shadow: IFShadow? = nil,
        specularBorder: Bool = false
    ) -> some View {
        modifier(IFSurfaceModifier(
            surface: surface,
            radius: radius,
            shadow: shadow ?? surface.defaultShadow,
            specularBorder: specularBorder
        ))
    }
}
