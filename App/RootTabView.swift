//
//  RootTabView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore
import FinUI

@MainActor
struct RootTabView: View {

    @Bindable var coordinator: AppCoordinator
    let sessionStore: SessionStore

    @Environment(AppCompositionRoot.self) private var root

    var body: some View {
        ZStack(alignment: .leading) {
            // Canvas global — compartido por todos los tabs (RGB 2, 9, 28)
            Color.ifNavy
                .ignoresSafeArea()

            tabContent
                // Interacción de profundidad: el contenido retrocede cuando se abre el drawer
                .scaleEffect(coordinator.isDrawerOpen ? 0.93 : 1.0)
                .offset(x: coordinator.isDrawerOpen ? 20 : 0)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: coordinator.isDrawerOpen ? IFRadius.lg : 0,
                        style: .continuous
                    )
                )
                .animation(IFMotion.panel, value: coordinator.isDrawerOpen)
                // Bloquea taps accidentales que pasen al contenido mientras el drawer está abierto
                .allowsHitTesting(!coordinator.isDrawerOpen)

            drawerOverlay
            DrawerView(coordinator: coordinator)
                .offset(x: coordinator.isDrawerOpen ? 0 : -DrawerView.drawerWidth)
                .allowsHitTesting(coordinator.isDrawerOpen)
                .animation(IFMotion.panel, value: coordinator.isDrawerOpen)
        }
        // Toda la app está diseñada solo para modo oscuro (canvas navy, tokens afinados para oscuro).
        // HomeView lo seteaba por vista; subirlo acá mantiene cada tab y sus destinos
        // pusheados en oscuro en lugar de seguir la apariencia del dispositivo, que dejaba
        // Mercado/Seguimiento/Portafolio con texto negro y tarjetas blancas en modo claro.
        .preferredColorScheme(.dark)
        .environment(coordinator)
        .environment(sessionStore)
        .sheet(item: $coordinator.activeTransfer) { flowType in
            transferSheet(for: flowType)
        }
        .sheet(isPresented: $coordinator.isProfilePresented) {
            profileSheet
        }
        .sheet(isPresented: $coordinator.isHistoryPresented) {
            historySheet
        }
        .sheet(isPresented: $coordinator.isWatchlistPresented) {
            watchlistSheet
        }
    }

    // MARK: - Sheet de perfil

    private var profileSheet: some View {
        NavigationStack {
            ProfileView(
                viewModel: ProfileViewModel(
                    userID: sessionStore.userID,
                    getUserProfileUseCase: root.getUserProfile,
                    logoutUseCase: root.logout,
                    sessionStore: sessionStore
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { coordinator.isProfilePresented = false }
                }
            }
        }
        .environment(coordinator)
        .environment(sessionStore)
    }

    // MARK: - Sheet de historial

    private var historySheet: some View {
        NavigationStack {
            TransactionHistoryView(
                viewModel: TransactionHistoryViewModel(
                    userID: sessionStore.userID,
                    getTransactionHistoryUseCase: root.getTransactionHistory
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { coordinator.isHistoryPresented = false }
                }
            }
        }
        .environment(coordinator)
    }

    // MARK: - Sheet de watchlist

    private var watchlistSheet: some View {
        NavigationStack {
            WatchlistView(
                viewModel: WatchlistViewModel(
                    userID: sessionStore.userID,
                    getWatchlistUseCase: root.getWatchlist,
                    removeFromWatchlistUseCase: root.removeFromWatchlist
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { coordinator.isWatchlistPresented = false }
                }
            }
        }
        .environment(coordinator)
    }

    // MARK: - Sheet de transferencia

    @ViewBuilder
    private func transferSheet(for flowType: TransferFlowType) -> some View {
        NavigationStack(path: $coordinator.transferNavPath) {
            CountrySelectionView(
                viewModel: CountrySelectionViewModel(
                    flowType: flowType,
                    userID: sessionStore.userID,
                    getSupportedCountriesUseCase: root.getSupportedCountries,
                    validateKYCUseCase: root.validateKYC
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { coordinator.dismissTransfer() }
                }
            }
            .navigationDestination(for: TransferRoute.self) { route in
                switch route {
                case .options(let country, let flowType):
                    TransferOptionsView(
                        viewModel: TransferOptionsViewModel(
                            country: country,
                            flowType: flowType,
                            getTransferOptionsUseCase: root.getTransferOptions
                        )
                    )
                case .enterAmount(let country, let method, let flowType):
                    TransferAmountView(
                        viewModel: TransferAmountViewModel(
                            country: country,
                            method: method,
                            flowType: flowType,
                            userID: sessionStore.userID
                        )
                    )
                case .confirm(let request):
                    TransferConfirmationView(
                        viewModel: TransferConfirmationViewModel(
                            request: request,
                            initiateTransfer: root.initiateTransfer
                        )
                    )
                case .result(let result):
                    TransferResultView(result: result)
                }
            }
        }
        .environment(coordinator)
    }

    // MARK: - Contenido de tabs

    @ViewBuilder
    private var tabContent: some View {
        TabView(selection: $coordinator.selectedTab) {

            NavigationStack(path: $coordinator.homePath) {
                HomeView(
                    viewModel: HomeViewModel(
                        userID: sessionStore.userID,
                        getUserProfileUseCase: root.getUserProfile,
                        getWatchlistUseCase: root.getWatchlist
                    )
                )
            }
            .toolbar(.hidden, for: .tabBar)
            .tabItem { Label(IFTab.home.title, systemImage: IFTab.home.icon) }
            .tag(IFTab.home)

            NavigationStack(path: $coordinator.marketPath) {
                MarketplaceView(
                    viewModel: MarketplaceViewModel(
                        getInstrumentsUseCase: root.getInstruments,
                        getTopMoversUseCase: root.getTopMovers,
                        getTrendingUseCase: root.getTrending,
                        getNewsUseCase: root.getMarketNews
                    )
                )
                .drawerToolbar()
                .navigationDestination(for: IFRoute.self) { route in
                    destinationView(for: route)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .tabItem { Label(IFTab.market.title, systemImage: IFTab.market.icon) }
            .tag(IFTab.market)

            NavigationStack(path: $coordinator.watchlistPath) {
                WatchlistView(
                    viewModel: WatchlistViewModel(
                        userID: sessionStore.userID,
                        getWatchlistUseCase: root.getWatchlist,
                        removeFromWatchlistUseCase: root.removeFromWatchlist
                    )
                )
                .drawerToolbar()
                .navigationDestination(for: IFRoute.self) { route in
                    destinationView(for: route)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .tabItem { Label(IFTab.watchlist.title, systemImage: IFTab.watchlist.icon) }
            .tag(IFTab.watchlist)

            NavigationStack(path: $coordinator.portfolioPath) {
                PortfolioView(
                    viewModel: PortfolioViewModel(
                        userID: sessionStore.userID,
                        getPortfolioUseCase: root.getPortfolio,
                        getTransactionHistoryUseCase: root.getTransactionHistory,
                        rebalanceUseCase: root.rebalance,
                        calculatePLUseCase: root.calculatePL,
                        getBreakdownUseCase: root.getPortfolioBreakdown,
                        getInsightsUseCase: root.getPortfolioInsights
                    )
                )
                .drawerToolbar()
                .navigationDestination(for: IFRoute.self) { route in
                    portfolioDestinationView(for: route)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .tabItem { Label(IFTab.portfolio.title, systemImage: IFTab.portfolio.icon) }
            .tag(IFTab.portfolio)
        }
        .tint(.ifBlue)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingTabBar(selection: $coordinator.selectedTab)
        }
    }

    // MARK: - Overlay del drawer

    private var drawerOverlay: some View {
        Color.black
            .ignoresSafeArea()
            .opacity(coordinator.isDrawerOpen ? 0.28 : 0)
            .animation(IFMotion.panel, value: coordinator.isDrawerOpen)
            .onTapGesture { coordinator.closeDrawer() }
            .allowsHitTesting(coordinator.isDrawerOpen)
    }

    // MARK: - Destinos de ruta

    @ViewBuilder
    private func destinationView(for route: IFRoute) -> some View {
        switch route {
        case .market:
            MarketListView(
                viewModel: MarketListViewModel(
                    getInstrumentsUseCase: root.getInstruments
                )
            )
        case .assetDetail(let id):
            AssetDetailView(
                viewModel: AssetDetailViewModel(
                    instrumentID: id,
                    userID: sessionStore.userID,
                    getAssetDetailUseCase: root.getAssetDetail,
                    refreshMarketDataUseCase: root.refreshMarket,
                    addToWatchlistUseCase: root.addToWatchlist,
                    removeFromWatchlistUseCase: root.removeFromWatchlist,
                    checkWatchlistStatusUseCase: root.checkWatchlistStatus
                )
            )
        case .orderForm(let id, let side):
            OrderFormView(
                viewModel: OrderFormViewModel(
                    instrumentID: id,
                    userID: sessionStore.userID,
                    getAssetDetailUseCase: root.getAssetDetail,
                    placeOrderUseCase: root.placeOrder,
                    initialSide: side
                )
            )
        case .portfolio:
            EmptyView()
                .onAppear { assertionFailure("IFRoute.portfolio no es navegable desde el tab Market") }
        case .portfolioDetail(_):
            EmptyView()
                .onAppear { assertionFailure("IFRoute.portfolioDetail no es navegable desde el tab Market") }
        }
    }

    @ViewBuilder
    private func portfolioDestinationView(for route: IFRoute) -> some View {
        switch route {
        case .portfolioDetail(let portfolio):
            PortfolioDetailView(
                viewModel: PortfolioDetailViewModel(
                    portfolio: portfolio,
                    getPerformanceUseCase: root.getPortfolioPerformance,
                    getHoldingsUseCase: root.getPortfolioHoldings
                )
            )
        default:
            EmptyView()
        }
    }
}
