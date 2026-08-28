//
//  IFCardStyle.swift
//  InvestFlow
//
//  Created by Stephano Portella on 09/05/2026.
//

import SwiftUI
import FinUI

// MARK: - IFCardStyle

/// ButtonStyle premium para superficies interactivas de tamaño tarjeta (≥ 100pt en cualquier dimensión).
///
/// ## Modelo de spring asimétrico
/// - **Press**: `cardPress` — response 0.18, totalmente sobreamortiguado (sin oscilación).
///   La animación se asienta tan rápido que se siente como contacto físico instantáneo.
/// - **Release**: `cardRelease` — response 0.40, damping 0.62 (leve sobrepaso).
///   La tarjeta rebota ~1.5% más allá de su estado de reposo antes de asentarse.
///   Ese único "pop" confirma que la interacción se completó, como el feedback del botón
///   home del iPhone.
///
/// ## Accesibilidad
/// Cuando `accessibilityReduceMotion` está activo:
/// - La animación de escala se desactiva (sin movimiento)
/// - En su lugar se aplica un cambio de opacidad a 0.88 (confirmación visual segura para la legibilidad)
struct IFCardStyle: ButtonStyle {

    /// Sombra en reposo. Se desvanece a cero al presionar — la tarjeta se "hunde" hacia la pantalla.
    /// El default es `.none` para tarjetas en listas densas o contextos de scroll horizontal.
    /// Pasar `.sm` para tarjetas standalone sobre fondos planos.
    var restShadow: IFShadow = .none

    func makeBody(configuration: Configuration) -> some View {
        IFCardContent(configuration: configuration, restShadow: restShadow)
    }
}

// MARK: - IFCardContent

/// Vista interna para acceder a @State + @Environment dentro de un ButtonStyle.
/// ButtonStyle en sí es un struct — @State y @Environment requieren un body de View.
private struct IFCardContent: View {

    let configuration: ButtonStyleConfiguration
    let restShadow: IFShadow

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1.0
    @State private var shadowAlpha: CGFloat = 1.0

    var body: some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1.0 : scale)
            // Fallback para reduce-motion: cambio de opacidad en lugar de escala.
            // Mantiene la descubribilidad sin disparar sensibilidad vestibular.
            .opacity(configuration.isPressed && reduceMotion ? 0.88 : 1.0)
            // Sombra controlada por shadowAlpha para que se desvanezca en sincronía con el spring de escala.
            // Cuando restShadow == .none (color: .clear, radius: 0), esto es un no-op.
            .shadow(
                color: restShadow.color.opacity(shadowAlpha),
                radius: restShadow.radius,
                x: restShadow.x,
                y: restShadow.y
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                withAnimation(pressed ? IFMotion.cardPress : IFMotion.cardRelease) {
                    scale = pressed ? 0.97 : 1.0
                    shadowAlpha = pressed ? 0.0 : 1.0
                }
            }
    }
}

// MARK: - Extensión de ButtonStyle

extension ButtonStyle where Self == IFCardStyle {

    /// Interacción de tarjeta — sin sombra en reposo.
    /// Para AssetCard en scrollers horizontales, SuggestedPortfolioCard en listas densas.
    static var ifCard: IFCardStyle { .init() }

    /// Interacción de tarjeta con una sombra en reposo que se desvanece al presionar.
    /// Para tarjetas standalone sobre fondos planos: `.ifCard(shadow: .sm)`.
    static func ifCard(shadow: IFShadow) -> IFCardStyle {
        IFCardStyle(restShadow: shadow)
    }
}

// MARK: - IFInteractiveModifier

/// Agrega feedback de press a nivel tarjeta a cualquier vista que no esté envuelta en un `Button`.
///
/// Usar cuando una superficie necesita animación táctil de press pero no puede ser un `Button` porque:
/// - Contiene elementos interactivos anidados (botones, pickers, gestos)
/// - Vive en una fila de `List` donde `Button` altera el layout/selección de la fila
/// - Responde a un reconocedor de gestos custom
///
/// La respuesta visual es idéntica a `IFCardStyle`: spring asimétrico, escala 0.97,
/// fade de sombra opcional. No dispara ninguna acción — para navegación usar `Button + .ifCard`.
///
/// ## Seguridad en scroll
/// Usa `onLongPressGesture(minimumDuration: .infinity, maximumDistance: 10)`.
/// El reconocedor se cancela cuando el toque se mueve > 10pt, así el estado de press se limpia durante el scroll.
/// Ambas animaciones de spring (`cardPress` / `cardRelease`) corren al entrar y salir del estado.
struct IFInteractiveModifier: ViewModifier {

    var shadow: IFShadow = .none

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1.0
    @State private var shadowAlpha: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .shadow(
                color: shadow.color.opacity(shadowAlpha),
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: 10,
                pressing: { pressing in
                    guard !reduceMotion else { return }
                    withAnimation(pressing ? IFMotion.cardPress : IFMotion.cardRelease) {
                        scale = pressing ? 0.97 : 1.0
                        shadowAlpha = pressing ? 0.0 : 1.0
                    }
                },
                perform: {}
            )
    }
}

extension View {

    /// Agrega feedback de press premium tipo tarjeta sin navegación.
    /// - Parameter shadow: Sombra en reposo que se desvanece al presionar. Default `.none`.
    func ifInteractive(shadow: IFShadow = .none) -> some View {
        modifier(IFInteractiveModifier(shadow: shadow))
    }
}

// MARK: - Vista previa

#Preview("Interaction System — Light") {
    InteractionPreview()
}

#Preview("Interaction System — Dark") {
    InteractionPreview()
        .preferredColorScheme(.dark)
}

private struct InteractionPreview: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    previewSection(".ifCard — cards interactivas") {
                        HStack(spacing: 12) {
                            cardButton(title: "Sin shadow", subtitle: ".none (lista densa)")
                                .buttonStyle(.ifCard)
                            cardButton(title: "Con shadow", subtitle: ".sm (standalone)")
                                .buttonStyle(.ifCard(shadow: .sm))
                        }
                    }

                    previewSection(".ifPress — acciones pequeñas") {
                        HStack(spacing: 0) {
                            ForEach(["Depositar", "Retirar", "Invertir"], id: \.self) { label in
                                Button {} label: {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.ifBlue.opacity(0.10))
                                            .frame(width: 52, height: 52)
                                            .overlay(
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(.ifBlue)
                                            )
                                        Text(label)
                                            .font(.system(size: 11))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.ifPress)
                            }
                        }
                    }

                    previewSection(".ifInteractive — surfaces no-Button") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Surface con nested elements")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Feedback táctil sin envolver en Button.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Material.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .ifInteractive()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
    }

    @ViewBuilder
    private func cardButton(title: String, subtitle: String) -> some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.ifBlue.opacity(0.10))
                    .frame(height: 36)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Material.regularMaterial,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func previewSection<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            content()
        }
    }
}
