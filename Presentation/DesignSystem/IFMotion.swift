//
//  IFMotion.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

/// Tokens de animación de spring de InvestFlow.
///
/// Todos los valores están ajustados para 60fps con chips serie A. Nunca usarlos dentro
/// de un LazyVStack de scroll rápido — el sistema de animación se dispara por celda y
/// causa caídas de frames a velocidad de lista. Usarlos en transiciones de estado
/// discretas, interacciones de press y secuencias estructuradas de entrada/salida.
nonisolated enum IFMotion {

    /// Spring rápido y ágil para press/elevación de botón. Damping bajo = leve rebote al soltar.
    /// Usar en: `IFPressStyle`, botones toggle, selección de pills.
    static let press = Animation.spring(response: 0.25, dampingFraction: 0.70)

    /// Spring suave para cambios de estado de UI — sin sobrepaso, sensación deliberada.
    /// Usar en: cambios de picker/tab, toggles de filtro, actualizaciones de badge.
    static let snap = Animation.spring(response: 0.30, dampingFraction: 0.88)

    /// Spring relajado para la entrada de elementos. Ease-in sutil con desaceleración natural.
    /// Usar en: `IFAppearModifier`, entrada de tarjetas, revelado de secciones.
    static let appear = Animation.spring(response: 0.50, dampingFraction: 0.82)

    /// Spring deliberado para transiciones de paneles grandes — drawer, sheets.
    /// Coincide con el spring de abrir/cerrar drawer de RootTabView (response: 0.3, dampingFraction: 0.85
    /// está lo bastante cerca como para que ambos paneles se muevan en armonía visual).
    static let panel = Animation.spring(response: 0.38, dampingFraction: 0.90)

    /// Spring sobreamortiguado para el hundimiento de la tarjeta al presionar. Sin oscilación
    /// — modela el contacto directo del dedo. El response rápido (0.18) mantiene la animación
    /// imperceptiblemente corta; el damping = 1.0 garantiza cero sobrepaso, así la escala
    /// nunca se "adelanta" al dedo durante el press.
    static let cardPress = Animation.spring(response: 0.18, dampingFraction: 1.0)

    /// Spring subamortiguado para la liberación de la tarjeta. El damping 0.62 produce un único
    /// sobrepaso sutil (~1.5% por encima de la escala de reposo) antes de asentarse — el rebote
    /// físico de una superficie comprimida. Es el "pop" que señala que la acción se completó,
    /// como en las propias tarjetas de Apple.
    static let cardRelease = Animation.spring(response: 0.40, dampingFraction: 0.62)
}
