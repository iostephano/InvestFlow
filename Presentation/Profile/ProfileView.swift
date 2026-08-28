//
//  ProfileView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import PhotosUI
import FinUI
import FinCore

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    @State private var showLogoutConfirm = false
    @Environment(SessionStore.self) private var sessionStore

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                LoadingView(message: "Cargando perfil...")
            case .loaded:
                content
            case .failed:
                errorView(viewModel.loadState.userMessage)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
        .confirmationDialog(
            "¿Cerrar sesión?",
            isPresented: $showLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                Task { await viewModel.logout() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Tendrás que volver a iniciar sesión para acceder a tu cuenta.")
        }
        .alert("Error al cerrar sesión", isPresented: .constant(viewModel.logoutError != nil)) {
            Button("OK") { }
        } message: {
            Text(viewModel.logoutError ?? "")
        }
    }

    // MARK: - Contenido

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                accountSection
                securitySection
                logoutButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(.ifBackground)
    }

    // MARK: - Encabezado de perfil

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ProfileAvatarPickerButton(
                avatarImageData: sessionStore.avatarImageData,
                initials: initials,
                onImageSelected: { data in sessionStore.setAvatar(data) }
            )

            VStack(spacing: 4) {
                Text(viewModel.profile?.fullName ?? "")
                    .font(.ifTitle)
                Text(viewModel.profile?.email ?? "")
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
            }

            HStack(spacing: 8) {
                kycBadge
                riskBadge
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var initials: String {
        guard let profile = viewModel.profile else { return "?" }
        let f = profile.firstName.prefix(1)
        let l = profile.lastName.prefix(1)
        return "\(f)\(l)".uppercased()
    }

    private var kycBadge: some View {
        let (label, color) = kycInfo
        return HStack(spacing: 4) {
            Image(systemName: "checkmark.shield.fill")
                .font(.caption2)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var kycInfo: (String, Color) {
        switch viewModel.profile?.kycStatus {
        case .approved: return ("KYC Aprobado", .ifGreen)
        case .pending:  return ("KYC Pendiente", .orange)
        case .inReview: return ("KYC En revisión", .orange)
        case .rejected: return ("KYC Rechazado", .ifRed)
        case .none:     return ("Sin KYC", .ifSecondary)
        }
    }

    private var riskBadge: some View {
        let label = riskLabel
        return HStack(spacing: 4) {
            Image(systemName: "chart.bar.fill")
                .font(.caption2)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.ifSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.ifSecondary.opacity(0.12), in: Capsule())
    }

    private var riskLabel: String {
        switch viewModel.profile?.riskProfile {
        case .conservative: return "Conservador"
        case .moderate:     return "Moderado"
        case .aggressive:   return "Agresivo"
        case .none:         return ""
        }
    }

    // MARK: - Sección de cuenta

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Cuenta")
            infoRow(
                label: "Saldo disponible",
                value: (viewModel.profile?.cashBalance ?? .zero)
                    .formatted(.currency(code: viewModel.profile?.currency.rawValue ?? "USD"))
            )
            Divider().padding(.leading, 16)
            infoRow(label: "Cuenta vinculada", value: "••••4521")
            Divider().padding(.leading, 16)
            infoRow(
                label: "Miembro desde",
                value: (viewModel.profile?.createdAt ?? Date())
                    .formatted(date: .abbreviated, time: .omitted)
            )
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Sección de seguridad

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Seguridad")
            if viewModel.isBiometricsAvailable {
                biometricsRow
            }
            Divider().padding(.leading, 16)
            infoRow(label: "Contraseña", value: "••••••••")
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var biometricsRow: some View {
        HStack {
            Image(systemName: biometricsIcon)
                .font(.system(size: 16))
                .foregroundStyle(.ifSecondary)
                .frame(width: 24)
            Text("Usar \(viewModel.biometryLabel)")
                .font(.ifBody)
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.isBiometricsEnabled },
                set: { _ in Task { await viewModel.toggleBiometrics() } }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var biometricsIcon: String {
        switch viewModel.biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "eye"
        case .none:    return "lock"
        }
    }

    // MARK: - Botón de cierre de sesión

    private var logoutButton: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            HStack {
                if viewModel.isLoggingOut {
                    ProgressView().tint(.ifRed)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Cerrar sesión")
                }
            }
            .font(.ifBody)
            .fontWeight(.medium)
            .foregroundStyle(.ifRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.isLoggingOut)
    }

    // MARK: - Auxiliares

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.ifSubhead)
            .foregroundStyle(.ifSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)
            Spacer()
            Text(value)
                .font(.ifBody)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.ifRed)
            Text(message)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Reintentar") { Task { await viewModel.load() } }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

// MARK: - ProfileAvatarPickerButton

/// Subview aislado para el avatar editable.
///
/// El closure label de PhotosPicker en iOS 26 es @Sendable. Cualquier computed property
/// del struct — sin excepción — es @MainActor-isolated porque @State hace que el tipo
/// entero sea @MainActor. La única solución garantizada es inlinear todo el contenido
/// y capturar explícitamente solo value types Sendable (Data?, String), eliminando la
/// captura implícita de self.
private struct ProfileAvatarPickerButton: View {

    let avatarImageData: Data?
    let initials: String
    let onImageSelected: @MainActor (Data) -> Void
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        // Capture list explícita: solo Data? y String — ambos Sendable.
        // self NO se captura → sin acceso a propiedades @MainActor-isolated.
        PhotosPicker(selection: $selectedItem, matching: .images) { [avatarImageData, initials] in
            Group {
                if let data = avatarImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay {
                            Circle().strokeBorder(Color.ifBlue.opacity(0.28), lineWidth: 1.5)
                        }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.ifBlue.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Text(initials)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(.ifBlue)
                    }
                }
            }
            // Badge — no accede a self ni a ningún valor capturado
            .overlay(alignment: .bottomTrailing) {
                ZStack {
                    Circle().fill(Material.regularMaterial)
                    Circle().fill(Color.ifBlue.opacity(0.14))
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.28), .white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.90))
                }
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.22), radius: 4, x: 0, y: 2)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItem) { _, item in
            Task { @MainActor in
                guard let item,
                      let raw = try? await item.loadTransferable(type: Data.self),
                      let source = UIImage(data: raw) else { return }
                // Redimensionar a máx 200 pt para mantener UserDefaults < 100 KB
                let maxSide: CGFloat = 200
                let scale = min(maxSide / source.size.width, maxSide / source.size.height)
                let newSize = CGSize(
                    width: max(source.size.width * scale, 1),
                    height: max(source.size.height * scale, 1)
                )
                let thumb = UIGraphicsImageRenderer(size: newSize).image { _ in
                    source.draw(in: CGRect(origin: .zero, size: newSize))
                }
                guard let jpeg = thumb.jpegData(compressionQuality: 0.85) else { return }
                onImageSelected(jpeg)
            }
        }
    }
}
