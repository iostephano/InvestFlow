//
//  SplashView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinUI

struct SplashView: View {

    @State private var appeared  = false
    @State private var glowPhase = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 36) {
                logoMark
                    .scaleEffect(appeared ? 1.0 : 0.72)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(IFMotion.appear, value: appeared)

                identity
                    .opacity(appeared ? 1.0 : 0.0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(IFMotion.appear.delay(0.14), value: appeared)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            appeared = true
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
        }
    }

    // MARK: - Marca / logo

    private var logoMark: some View {
        ZStack {
            // Halo ambiental azul exterior — pulsa
            Circle()
                .fill(Color.ifBlue.opacity(glowPhase ? 0.20 : 0.08))
                .blur(radius: 42)
                .frame(width: 172, height: 172)
                .allowsHitTesting(false)

            // Bloom violeta interior — en contra-frecuencia
            Circle()
                .fill(Color.ifViolet.opacity(glowPhase ? 0.11 : 0.04))
                .blur(radius: 30)
                .frame(width: 128, height: 128)
                .allowsHitTesting(false)

            // Marca — squircle navy + flecha ascendente, refleja el icono de la app
            InvestFlowMark(size: 96, glow: true)
        }
    }

    // MARK: - Identidad

    private var identity: some View {
        VStack(spacing: 10) {
            Text("InvestFlow")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Empieza a invertir hoy")
                .font(.system(size: 14, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.44))
        }
    }
}

#Preview {
    SplashView()
}
