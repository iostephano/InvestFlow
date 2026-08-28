//
//  LoginView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct LoginView: View {

    @State private var viewModel: LoginViewModel
    @State private var appeared = false

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 36) {
                        logoSection
                        formSection
                        actionSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(IFMotion.appear) { appeared = true }
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 18) {
            // Marca — mismo squircle navy + flecha ascendente que el splash y el icono de la app
            ZStack {
                Circle()
                    .fill(Color.ifBlue.opacity(0.16))
                    .blur(radius: 28)
                    .frame(width: 108, height: 108)
                    .allowsHitTesting(false)

                Circle()
                    .fill(Color.ifViolet.opacity(0.09))
                    .blur(radius: 20)
                    .frame(width: 84, height: 84)
                    .allowsHitTesting(false)

                InvestFlowMark(size: 64, glow: true)
            }

            VStack(spacing: 6) {
                Text("InvestFlow")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Empieza a invertir hoy")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(0.4)
                    .foregroundStyle(.white.opacity(0.44))
            }
        }
        .opacity(appeared ? 1.0 : 0.0)
        .scaleEffect(appeared ? 1.0 : 0.88)
        .animation(IFMotion.appear, value: appeared)
    }

    // MARK: - Formulario

    private var formSection: some View {
        VStack(spacing: 16) {
            inputField(label: "Email") {
                TextField("tu@email.com", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            inputField(label: "Contraseña") {
                SecureField("••••••••", text: $viewModel.password)
            }

            if let message = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.ifRed)
                    Text(message)
                        .font(.ifSubhead)
                        .foregroundStyle(.ifRed)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
                        .fill(Color.ifRed.opacity(0.10))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: IFRadius.sm, style: .continuous)
                        .strokeBorder(Color.ifRed.opacity(0.28), lineWidth: 0.75)
                }
            }
        }
        .tint(Color.ifBlue)
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 10)
        .animation(IFMotion.appear.delay(0.10), value: appeared)
    }

    @ViewBuilder
    private func inputField<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.ifCaption)
                .foregroundStyle(.white.opacity(0.50))

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                        .fill(Color(red: 0.09, green: 0.10, blue: 0.22))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.18), location: 0.0),
                                    .init(color: .white.opacity(0.07), location: 0.5),
                                    .init(color: .white.opacity(0.02), location: 1.0),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
        }
    }

    // MARK: - Acción

    private var actionSection: some View {
        VStack(spacing: 14) {
            Button {
                Task { await viewModel.login() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white).scaleEffect(0.85)
                    }
                    Text(viewModel.isLoading ? "Iniciando sesión..." : "Iniciar sesión")
                        .font(.ifHeadline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.liquidGlass)
            .disabled(!viewModel.canLogin)
            .opacity(viewModel.canLogin ? 1.0 : 0.38)

            Text("Al continuar aceptas los Términos de Uso y la Política de Privacidad de InvestFlow.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.28))
                .multilineTextAlignment(.center)
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 10)
        .animation(IFMotion.appear.delay(0.18), value: appeared)
    }
}
