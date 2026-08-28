//
//  AppCoordinator.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore

/// Rutas de navegación de la app InvestFlow.
enum IFRoute: Hashable {
    case market
    case assetDetail(instrumentID: String)
    case orderForm(instrumentID: String, side: OrderSide)
    case portfolio
    case portfolioDetail(portfolio: SuggestedPortfolio)
}

/// Tab principal de InvestFlow.
enum IFTab: CaseIterable {
    case home
    case market
    case watchlist
    case portfolio

    var title: String {
        switch self {
        case .home:      return "Inicio"
        case .market:    return "Mercado"
        case .watchlist: return "Seguimiento"
        case .portfolio: return "Portafolio"
        }
    }

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .market:    return "chart.line.uptrend.xyaxis"
        case .watchlist: return "star"
        case .portfolio: return "briefcase"
        }
    }
}

/// Rutas del flujo de transferencia (dentro del sheet modal).
enum TransferRoute: Hashable {
    case options(country: SupportedCountry, flowType: TransferFlowType)
    case enterAmount(country: SupportedCountry, method: TransferOption, flowType: TransferFlowType)
    case confirm(request: TransferRequest)
    case result(TransferResult)
}

@MainActor
@Observable
final class AppCoordinator {

    var selectedTab: IFTab = .home
    var homePath = NavigationPath()
    var marketPath = NavigationPath()
    var watchlistPath = NavigationPath()
    var portfolioPath = NavigationPath()

    // MARK: - Sheets de perfil, historial y watchlist

    var isProfilePresented:   Bool = false
    var isHistoryPresented:   Bool = false
    var isWatchlistPresented: Bool = false

    // MARK: - Estado del drawer

    var isDrawerOpen: Bool = false

    func openDrawer()  { isDrawerOpen = true }
    func closeDrawer() { isDrawerOpen = false }

    // MARK: - Estado del flujo de transferencia

    /// Non-nil cuando el sheet de transferencia está activo.
    var activeTransfer: TransferFlowType? = nil
    var transferNavPath = NavigationPath()

    // MARK: - Acciones de navegación

    func showAssetDetail(instrumentID: String) {
        marketPath.append(IFRoute.assetDetail(instrumentID: instrumentID))
    }

    func showWatchlistDetail(instrumentID: String) {
        watchlistPath.append(IFRoute.assetDetail(instrumentID: instrumentID))
    }

    func showOrderForm(instrumentID: String, side: OrderSide = .buy) {
        marketPath.append(IFRoute.orderForm(instrumentID: instrumentID, side: side))
    }

    func popToMarketRoot() {
        marketPath.removeLast(marketPath.count)
    }

    func navigateToMarket() {
        selectedTab = .market
        closeDrawer()
    }

    func navigateToFullMarket() {
        marketPath.append(IFRoute.market)
    }

    func navigateToWatchlist() {
        selectedTab = .watchlist
        closeDrawer()
    }

    func navigateToPortfolio() {
        selectedTab = .portfolio
        closeDrawer()
    }

    func showPortfolioDetail(_ portfolio: SuggestedPortfolio) {
        selectedTab = .portfolio
        portfolioPath.append(IFRoute.portfolioDetail(portfolio: portfolio))
    }

    // MARK: - Acciones de transferencia

    func startDeposit() {
        activeTransfer = .deposit
        transferNavPath = NavigationPath()
        closeDrawer()
    }

    func startWithdrawal() {
        activeTransfer = .withdrawal
        transferNavPath = NavigationPath()
        closeDrawer()
    }

    func navigateToTransferConfirmation(request: TransferRequest) {
        transferNavPath.append(TransferRoute.confirm(request: request))
    }

    func dismissTransfer() {
        activeTransfer = nil
        transferNavPath = NavigationPath()
    }

    // MARK: - Acciones de perfil, historial y watchlist

    func showProfile() {
        isProfilePresented = true
        closeDrawer()
    }

    func showTransactionHistory() {
        isHistoryPresented = true
        closeDrawer()
    }

    func showWatchlist() {
        isWatchlistPresented = true
        closeDrawer()
    }

    // MARK: - Cierre de sesión

    func performLogout() {
        isProfilePresented   = false
        isHistoryPresented   = false
        isWatchlistPresented = false
        activeTransfer = nil
        isDrawerOpen = false
        homePath = NavigationPath()
        marketPath = NavigationPath()
        watchlistPath = NavigationPath()
        portfolioPath = NavigationPath()
        selectedTab = .home
    }
}
