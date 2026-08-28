//
//  HomeView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI
import FinCore

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @State private var navScrolled = false
    @State private var carouselPage = HomeView.carouselStart
    @State private var selectedPromoCard: HomeViewModel.PromoCard? = nil
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(SessionStore.self) private var sessionStore

    private static let carouselCount = HomeViewModel.PromoCard.defaultCards.count
    private static let carouselTotal = carouselCount * 100
    private static let carouselStart = carouselCount * 50   // mid-point, multiple of count

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Group {
                switch viewModel.loadState {
                case .idle, .loading:
                    LoadingView(message: "Cargando inicio...")
                case .loaded:
                    homeContent
                case .failed:
                    ErrorStateView(message: viewModel.loadState.userMessage) {
                        Task { await viewModel.retry() }
                    }
                }
            }
        }
        .background(Color.ifNavy)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if navScrolled {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { coordinator.openDrawer() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .toolbarBackground(Color.ifNavy, for: .navigationBar)
        .toolbarBackground(navScrolled ? .visible : .hidden, for: .navigationBar)
        .task { await viewModel.load() }
        // Fuerza el render oscuro para que todos los Material y colores del sistema
        // resuelvan a sus variantes oscuras sobre el canvas raíz ifNavy. Acotado solo a
        // HomeView — no afecta a los sheets (que son de RootTabView) ni a otros tabs.
        .preferredColorScheme(.dark)
        .sheet(item: $selectedPromoCard) { card in
            PromoDetailView(card: card)
        }
    }

    // MARK: - Contenido de Inicio

    private var homeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header inline — se desplaza con el contenido; la nav bar aparece con fade cuando este sale del viewport
                premiumHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 18)
                    .ifAppear(delay: 0)

                HomeHeroCard(
                    amount: viewModel.buyingPower,
                    onTap: { coordinator.navigateToPortfolio() }
                )
                .padding(.horizontal, 20)
                .ifAppear(delay: 0.06)

                quickActionsSection
                    .padding(.top, 20)
                    .ifAppear(delay: 0.12)

                promoCardsSection
                    .padding(.top, 20)
                    .ifAppear(delay: 0.18)

                // Siempre visible: el estado vacío se maneja dentro de MyAssetsSnapshotView.
                myAssetsSection
                    .padding(.top, 12)
                    .ifAppear(delay: 0.22)
            }
            // El espacio extra al fondo asegura que "En seguimiento" quede totalmente por encima
            // de la FloatingTabBar (safeAreaInset de 76 pt) con un margen cómodo.
            .padding(.bottom, 100)
        }
        .background(Color.ifNavy)
        // Umbral fijado en 88 pt — la altura total del header (8 arriba + 44 contenido + 18 abajo + buffer)
        // asegura que la hamburguesa inline esté totalmente fuera de vista antes de que aparezca la de la nav bar.
        .ifScrollOffset(threshold: 88) { scrolled in
            withAnimation(IFMotion.snap) { navScrolled = scrolled }
        }
    }

    // MARK: - Encabezado premium

    private var premiumHeader: some View {
        // Layout: [hamburguesa] [identidad anclada a la izquierda] [spacer] [avatar]
        // La identidad anclada a la izquierda refleja los dashboards bancarios premium — evita la
        // apariencia centrada por defecto de SwiftUI y crea un flujo direccional más fuerte hacia la hero card.
        HStack(alignment: .center, spacing: 12) {

            // Hamburguesa — círculo iridiscente premium
            Button(action: { coordinator.openDrawer() }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .ifGlow(color: .ifBlue, radius: 6)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.10), in: Circle())
                    .premiumSpecularBorder(cornerRadius: 20, lineWidth: 0.75, animated: true)
            }
            .buttonStyle(.plain)

            // Identidad — anclada a la izquierda, jerarquía más ajustada que el enfoque centrado
            VStack(alignment: .leading, spacing: 3) {
                Text(timeGreeting)
                    .font(.ifCaption)
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.48))
                Text(viewModel.userName.isEmpty ? "InvestFlow" : viewModel.userName)
                    .font(.ifTitle)
                    .foregroundStyle(.white)
            }

            Spacer()

            // Avatar — muestra foto de perfil si existe, iniciales como fallback.
            Button(action: { coordinator.isProfilePresented = true }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .overlay {
                            if sessionStore.avatarImageData == nil {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.ifBlue.opacity(0.46),
                                                Color.ifViolet.opacity(0.26)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .overlay {
                            Circle().strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.40), .white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                        }
                    if let data = sessionStore.avatarImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        Text(viewModel.userName.first.map { String($0).uppercased() } ?? "H")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .ifGlow(color: .ifBlue, radius: 5)
                    }
                }
                .frame(width: 44, height: 44)
                .ifGlow(color: .ifBlue, radius: 8)
            }
            .buttonStyle(.ifPress)
        }
    }

    private var timeGreeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 0..<12:  return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default:      return "Buenas noches"
        }
    }

    // MARK: - Acciones rápidas

    private var quickActionsSection: some View {
        QuickActionsView(actions: viewModel.quickActions) { action in
            handleQuickAction(action)
        }
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                    .fill(Material.thinMaterial)
                // Realce tonal — mantiene el panel visible sobre la base navy oscura
                RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.16, blue: 0.36).opacity(0.55))
            }
        }
        .premiumSpecularBorder(cornerRadius: IFRadius.md, lineWidth: 1.0)
        .cardGlow(color: .ifBlue, radius: 22, opacity: 0.14)
        .padding(.horizontal, 20)
    }

    // MARK: - Tarjetas promocionales

    private var promoCardsSection: some View {
        let cards = viewModel.promotionalCards
        let count = Self.carouselCount

        return VStack(alignment: .leading, spacing: 10) {
            Text("Para ti")
                .font(.ifHeadline)
                .padding(.horizontal, 20)

            // Carrusel de páginas a ancho completo — una tarjeta a la vez, loop infinito vía
            // carouselTotal×100 ítems. Se quitaron los puntos para reducir el espacio vertical.
            TabView(selection: $carouselPage) {
                ForEach(0..<Self.carouselTotal, id: \.self) { idx in
                    Button {
                        selectedPromoCard = cards[idx % count]
                    } label: {
                        PromoCardView(card: cards[idx % count])
                    }
                    .buttonStyle(.plain)
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
            .padding(.horizontal, 20)
        }
        // Autoplay: el timer se reinicia después de cada cambio de página (swipe o automático)
        .task(id: carouselPage) {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeInOut(duration: 0.40)) {
                carouselPage += 1
            }
        }
    }

    // MARK: - Mis activos

    private var myAssetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("En seguimiento")
                .font(.ifSubhead.weight(.semibold))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.horizontal, 20)

            Button { coordinator.navigateToWatchlist() } label: {
                MyAssetsSnapshotView(entries: viewModel.watchlistSnapshot)
            }
            .buttonStyle(.ifCard)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Navegación

    private func handleQuickAction(_ action: HomeViewModel.QuickActionType) {
        switch action {
        case .deposit:
            coordinator.startDeposit()
        case .withdraw:
            coordinator.startWithdrawal()
        case .invest:
            coordinator.navigateToMarket()
        }
    }

}

// MARK: - PromoDetailView

private struct PromoDetailView: View {

    let card: HomeViewModel.PromoCard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.14)
                    .ignoresSafeArea()

                // Glow de acento — arriba-derecha, sigue el lenguaje visual de la tarjeta
                RadialGradient(
                    colors: [themeColor.opacity(0.22), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 280
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        ZStack {
                            Circle()
                                .fill(themeColor.opacity(0.14))
                                .frame(width: 80, height: 80)
                            Circle()
                                .strokeBorder(themeColor.opacity(0.28), lineWidth: 1)
                                .frame(width: 80, height: 80)
                            Image(systemName: iconName)
                                .font(.system(size: 34, weight: .medium))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(themeColor)
                                .ifGlow(color: themeColor, radius: 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.title)
                                .font(.ifTitle)
                                .foregroundStyle(.white)
                            Text(card.subtitle)
                                .font(.ifSubhead)
                                .foregroundStyle(.white.opacity(0.65))
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(bullets, id: \.self) { bullet in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(themeColor)
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 7)
                                    Text(bullet)
                                        .font(.ifBody)
                                        .foregroundStyle(.white.opacity(0.78))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                        }

                        Button { dismiss() } label: {
                            Text("Explorar")
                                .font(.ifBody)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(themeColor, in: RoundedRectangle(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(.white.opacity(0.18), lineWidth: 0.5)
                                }
                        }
                        .shadow(color: themeColor.opacity(0.38), radius: 16, x: 0, y: 6)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.white.opacity(0.70))
                }
            }
            .toolbarBackground(Color(red: 0.06, green: 0.07, blue: 0.14), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var themeColor: Color {
        switch card.theme {
        case .blue:   return .ifBlue
        case .green:  return .ifGreen
        case .purple: return .ifViolet
        }
    }

    private var iconName: String {
        switch card.theme {
        case .blue:   return "chart.pie.fill"
        case .green:  return "bitcoinsign.circle.fill"
        case .purple: return "repeat.circle.fill"
        }
    }

    private var bullets: [String] {
        switch card.theme {
        case .blue:
            return [
                "Accede a más de 100 ETFs globales desde una sola cuenta.",
                "Distribuye tu capital automáticamente entre sectores y regiones.",
                "Reduce el riesgo con estrategias de diversificación inteligente."
            ]
        case .green:
            return [
                "Opera Bitcoin, Ethereum y más criptomonedas en tiempo real.",
                "Sin límites de monto — desde $1 hasta lo que necesites.",
                "Precio en vivo con spread transparente y ejecución inmediata."
            ]
        case .purple:
            return [
                "Programa aportaciones automáticas desde $10 al mes.",
                "InvestFlow reinvierte tus retornos para maximizar el crecimiento compuesto.",
                "Pausa o cancela cuando quieras, sin penalizaciones."
            ]
        }
    }
}
