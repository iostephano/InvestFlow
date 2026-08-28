//
//  IFPressStyle.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

/// Un `ButtonStyle` que señala profundidad interactiva: spring de escala + opacidad al presionar.
///
/// Aporta sensación táctil sin cambios de layout. Los valores de escala y opacidad están
/// calibrados al propio patrón de card-press de Apple en Stocks.app y App Store:
/// - escala 0.96: claramente visible pero sin ser abrupta
/// - opacidad 0.88: atenúa la superficie de vidrio, reforzando la metáfora de "presionado hacia dentro"
///
/// Reemplaza a `.plain` en cualquier botón de tarjeta o icono. NO usar en CTAs destructivos
/// (`.borderedProminent`) — esos usan la animación de press del sistema.
struct IFPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(IFMotion.press, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == IFPressStyle {
    static var ifPress: IFPressStyle { .init() }
}
