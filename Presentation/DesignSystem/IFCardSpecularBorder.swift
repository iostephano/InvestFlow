//
//  IFCardSpecularBorder.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI

// MARK: - PremiumSpecularBorderModifier

/// strokeBorder iridiscente animado para superficies de tarjeta premium.
///
/// Dibuja un trazo fino `AngularGradient` cuyo espectro de color fluye alrededor del
/// borde de la tarjeta: ifBlue → cian apagado → ifGreen → blanco → ifViolet → ifBlue.
/// Una única variable de estado `Double` impulsa una oscilación de fase de 180° vía
/// `withAnimation`; SwiftUI reevalúa `body` en cada frame con el valor interpolado,
/// produciendo una rotación suave a 60 fps sin el costo de Canvas, blur ni sombra.
///
/// ## Lenguaje visual
/// La paleta se lee como titanio/vidrio iridiscente — inspirada en el Apple Watch Ultra
/// y en acabados metálicos premium. NO es neón/RGB: todos los tonos están desaturados por
/// sus valores de opacidad y se apoyan sobre un fondo navy oscuro que los apaga aún más.
///
/// ## Contrato de rendimiento
/// - Anima un `Double` por tarjeta.
/// - Sin pasada de blur, sin capa de sombra, sin shader custom de Metal.
/// - Solo redibuja el overlay del strokeBorder de 1 pt por frame.
/// - Seguro dentro de un contenedor de scroll no-lazy (HomeView).
struct PremiumSpecularBorderModifier: ViewModifier {

    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let animated: Bool

    // Impulsa el barrido de 180° de ida/vuelta del AngularGradient.
    // SwiftUI interpola este Double en cada frame durante la animación repeatForever,
    // haciendo que body se vuelva a ejecutar con el valor de fase actual.
    @State private var phase: Double = 0

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    // Espectro iridiscente de 6 stops, con loop cerrado (primer color == último).
    // Cian apagado = Color(0.28, 0.82, 0.96) para evitar la saturación neón del cian del sistema.
    // El blanco en 0.78 aporta el pico del reflejo especular.
    // Los ifBlue en los extremos garantizan un loop de gradiente sin costuras.
    private var gradient: AngularGradient {
        AngularGradient(
            colors: [
                Color.ifBlue.opacity(0.82),
                Color(red: 0.28, green: 0.82, blue: 0.96).opacity(0.68),
                Color.ifGreen.opacity(0.58),
                Color.white.opacity(0.78),
                Color.ifViolet.opacity(0.72),
                Color.ifBlue.opacity(0.82),
            ],
            center: .center,
            startAngle: .degrees(phase),
            endAngle:   .degrees(phase + 360)
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay { shape.strokeBorder(gradient, lineWidth: lineWidth) }
            .onAppear {
                guard animated else { return }
                // Barre 180° hacia adelante (6 s easeInOut) y luego 180° de vuelta — ciclo total de 12 s.
                // repeatForever(autoreverses: true) produce la oscilación de "ida y vuelta".
                withAnimation(
                    .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
                ) {
                    phase = 180
                }
            }
    }
}

// MARK: - Extensión de View

extension View {

    /// Aplica un borde especular premium animado.
    ///
    /// - Parameters:
    ///   - cornerRadius: Radio de esquina continuo. Usar tokens `IFRadius`.
    ///   - lineWidth:    Ancho del trazo en puntos. Default `1.0`.
    ///   - animated:     Activa la oscilación de fase de 180° de ida/vuelta. Default `true`.
    func premiumSpecularBorder(
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1.0,
        animated: Bool = true
    ) -> some View {
        modifier(PremiumSpecularBorderModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            animated: animated
        ))
    }
}
