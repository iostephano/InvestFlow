//
//  IFAppear.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

/// Animación de entrada: fade + elevación desde 8pt abajo, con desaceleración de spring.
///
/// Segura en cualquier vista. El parámetro `delay` permite escalonar una serie de
/// vistas hermanas para un efecto de revelado en cascada.
///
/// ## Contrato de rendimiento
/// - Solo dispara `onAppear` — sin seguimiento de posición de scroll, sin GeometryReader.
/// - Anima solo `opacity` y `offset` — sin propiedades de layout, sin blur.
/// - Segura dentro de `LazyVStack` SOLO para secciones/contenedores, no para filas
///   individuales en una lista de scroll rápido (cada aparición de fila se dispara a la
///   velocidad del scroll).
struct IFAppearModifier: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 8)
            .animation(IFMotion.appear.delay(delay), value: visible)
            .onAppear { visible = true }
    }
}

extension View {
    func ifAppear(delay: Double = 0) -> some View {
        modifier(IFAppearModifier(delay: delay))
    }
}
