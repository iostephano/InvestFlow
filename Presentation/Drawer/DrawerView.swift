//
//  DrawerView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinCore
import FinUI

// MARK: - Ítem del drawer

enum DrawerItem: CaseIterable, Identifiable {
    case profile
    case history
    case watchlist
    case portfolio
    case transfer
    case logout

    var id: Self { self }

    var title: String {
        switch self {
        case .profile:   return "Perfil"
        case .history:   return "Historial"
        case .watchlist: return "Seguimiento"
        case .portfolio: return "Portafolio"
        case .transfer:  return "Transferir fondos"
        case .logout:    return "Cerrar sesión"
        }
    }

    var icon: String {
        switch self {
        case .profile:   return "person.circle"
        case .history:   return "clock.arrow.circlepath"
        case .watchlist: return "star.circle"
        case .portfolio: return "briefcase"
        case .transfer:  return "arrow.left.arrow.right.circle"
        case .logout:    return "rectangle.portrait.and.arrow.right"
        }
    }

    var isDestructive: Bool { self == .logout }
}

// MARK: - DrawerView

struct DrawerView: View {

    static let drawerWidth: CGFloat = 280

    let coordinator: AppCoordinator

    @Environment(SessionStore.self) private var sessionStore
    @Environment(AppCompositionRoot.self) private var composition

    @State private var showLogoutConfirm = false
    @State private var isLoggingOut = false
    @State private var logoutError: String?

    // MARK: - Forma

    private var panelShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: IFRadius.lg,
            topTrailingRadius: IFRadius.lg,
            style: .continuous
        )
    }

    // MARK: - Cuerpo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            drawerHeader
            drawerDivider
            drawerItems
            Spacer()
        }
        .frame(width: Self.drawerWidth)
        .frame(maxHeight: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .trailing) { trailingEdgeHighlight }
        .clipShape(panelShape)
        .shadow(color: .black.opacity(0.12), radius: 32, x: 16, y: 0)
        .ignoresSafeArea(edges: .vertical)
        .confirmationDialog(
            "¿Cerrar sesión?",
            isPresented: $showLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                Task { await performLogout() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Tendrás que volver a iniciar sesión para acceder a tu cuenta.")
        }
        .alert(
            "Error al cerrar sesión",
            isPresented: Binding(
                get: { logoutError != nil },
                set: { if !$0 { logoutError = nil } }
            )
        ) {
            Button("OK") { logoutError = nil }
        } message: {
            Text(logoutError ?? "")
        }
    }

    // MARK: - Reflejo especular del borde derecho

    private var trailingEdgeHighlight: some View {
        LinearGradient(
            colors: [.white.opacity(0.22), .white.opacity(0.04)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 0.5)
        .clipShape(panelShape)
    }

    // MARK: - Divisor

    private var drawerDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 0.5)
            .padding(.horizontal, 20)
    }

    // MARK: - Encabezado

    private var drawerHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                InvestFlowMark(size: 44)
                Text("InvestFlow")
                    .font(.ifTitle)
                Text("Tu app de inversiones")
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
            }
            Spacer()
            Button(action: coordinator.closeDrawer) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.ifPress)
        }
        .padding(.horizontal, 20)
        .padding(.top, 64)
        .padding(.bottom, 20)
    }

    // MARK: - Ítems

    private var drawerItems: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach([DrawerItem.profile, .history, .watchlist, .portfolio, .transfer], id: \.id) { item in
                drawerRow(item)
            }

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

            drawerRow(.logout)
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func drawerRow(_ item: DrawerItem) -> some View {
        Button {
            handleTap(item)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(item.isDestructive ? .ifRed : .ifSecondary)
                    .frame(width: 24)
                Text(item.title)
                    .font(.ifBody)
                    .foregroundStyle(item.isDestructive ? .ifRed : .primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.ifPress)
    }

    // MARK: - Navegación

    private func handleTap(_ item: DrawerItem) {
        switch item {
        case .profile:
            coordinator.showProfile()
        case .history:
            coordinator.showTransactionHistory()
        case .watchlist:
            coordinator.navigateToWatchlist()
        case .portfolio:
            coordinator.navigateToPortfolio()
        case .transfer:
            coordinator.startDeposit()
        case .logout:
            // Confirmar primero, y recién ahí invalidar la sesión de verdad (igual que
            // ProfileView). `AppCoordinator.performLogout()` solo resetea la navegación —
            // corre de forma reactiva una vez que la sesión termina.
            showLogoutConfirm = true
        }
    }

    private func performLogout() async {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        logoutError = nil
        defer { isLoggingOut = false }
        do {
            try await composition.logout.execute()
            sessionStore.signOut()
        } catch {
            IFLogger.error(error, context: "DrawerView.performLogout")
            logoutError = IFError.from(error).userMessage
        }
    }
}
