//
//  IFScrollEffect.swift
//  InvestFlow
//
//  Created by Stephano Portella on 09/05/2026.
//

import SwiftUI

// MARK: - ifScrollEdge

extension View {

    /// Efecto de profundidad de escala + opacidad para ítems dentro de ScrollViews horizontales.
    ///
    /// ## Modelo de render
    /// `.scrollTransition` lo maneja por completo el compositor de la GPU (Core Animation).
    /// NO observa la geometría del scroll desde la CPU — sin `onChange`, sin `@State`,
    /// sin pasadas de layout disparadas por frame. Los valores de transform se pasan a
    /// CALayer y se interpolan en el render thread.
    ///
    /// Costo de CPU por frame de scroll: cero.
    /// Seguro en: `LazyHStack`, `HStack`, scrollers horizontales de swipe rápido.
    ///
    /// ## Semántica de las fases (scroll horizontal)
    /// - `.topLeading`     → el ítem está a la IZQUIERDA, ya pasó del scroll
    /// - `.identity`       → el ítem está visible en la ventana de scroll
    /// - `.bottomTrailing` → el ítem está a la DERECHA, todavía no entró a la vista
    ///
    /// Asimetría intencional: la izquierda está más desvanecida (el usuario ya avanzó),
    /// la derecha está levemente atenuada (asomándose). Crea un gradiente de profundidad en la bandeja.
    ///
    /// ## Accesibilidad
    /// `.scrollTransition` respeta `accessibilityReduceMotion` automáticamente.
    /// No hace falta manejo adicional.
    ///
    /// No combinar con `.ifAppear()` en la misma vista: ambos animan opacidad y entran en
    /// conflicto en la primera carga. `.ifScrollEdge()` es para tarjetas horizontales;
    /// `.ifAppear()`, para secciones verticales (entrada de una sola vez, sin seguimiento continuo).
    func ifScrollEdge() -> some View {
        scrollTransition(.animated(IFMotion.snap)) { content, phase in
            content
                .opacity(
                    phase.isIdentity ? 1.0
                    : phase == .topLeading ? 0.58
                    : 0.80
                )
                .scaleEffect(
                    phase.isIdentity ? 1.0
                    : phase == .topLeading ? 0.92
                    : 0.96,
                    anchor: .center
                )
        }
    }
}

// MARK: - ifScrollOffset

extension View {

    /// Dispara un callback booleano de umbral cuando el offset de un ScrollView cruza un límite.
    /// Usa `onScrollGeometryChange` — lee de la capa de scroll post-layout,
    /// SIN invalidar el árbol de vistas, SIN GeometryReader, SIN PreferenceKey.
    ///
    /// ## Por qué no GeometryReader
    /// GeometryReader participa en la pasada de layout. Cada frame de scroll dispara un
    /// recálculo de layout de todo el subárbol bajo el GeometryReader. En una pantalla de
    /// 120Hz eso son 120 pasadas de layout/segundo — la causa principal de caídas de frames
    /// relacionadas con el scroll en SwiftUI.
    ///
    /// `onScrollGeometryChange` lee la geometría DESPUÉS de que termina el layout, en el
    /// render thread. El closure de valor `for:` se evalúa una vez por frame pero SOLO dispara
    /// `action:` cuando el valor extraído cambia de verdad. Con un extractor `Bool`,
    /// `action:` se dispara a lo sumo dos veces: al cruzar y al des-cruzar.
    ///
    /// ## Offset normalizado
    /// `contentOffset.y + contentInsets.top` da la posición del scroll relativa a la
    /// posición inicial natural del contenido, teniendo en cuenta el inset superior del safe area.
    /// El valor es 0 arriba, positivo al bajar — independientemente del dispositivo.
    func ifScrollOffset(
        threshold: CGFloat = 16,
        onChange: @escaping @MainActor (Bool) -> Void
    ) -> some View {
        onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > threshold
        } action: { _, isScrolled in
            onChange(isScrolled)
        }
    }
}
