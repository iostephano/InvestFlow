//
//  AppCompositionRoot.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore
import Observation

/// Se crea una sola vez en `InvestFlowApp` y se inyecta a través del entorno
/// de SwiftUI (`@Environment(AppCompositionRoot.self)`), de forma simétrica a
/// `SessionStore` y `AppCoordinator`. Las vistas no deben recurrir a un global —
/// `preview` existe solo para bloques `#Preview` y tests.
@MainActor
@Observable
final class AppCompositionRoot {

    /// Solo para previews de SwiftUI y tests — nunca se usa desde vistas de producción.
    static let preview = AppCompositionRoot()

    // MARK: - Repositorios

    let marketRepo:    any MarketRepositoryProtocol
    let portfolioRepo: any PortfolioRepositoryProtocol
    let orderRepo:     any OrderRepositoryProtocol
    let transferRepo:  any TransferRepositoryProtocol
    let authRepo:      any AuthRepositoryProtocol
    let watchlistRepo: any WatchlistRepositoryProtocol

    // MARK: - Casos de uso

    let getInstruments:        GetInstrumentsUseCase
    let getAssetDetail:        GetAssetDetailUseCase
    let refreshMarket:         RefreshMarketDataUseCase
    let placeOrder:            PlaceOrderUseCase
    let calculatePL:           CalculatePLUseCase
    let getPortfolioBreakdown: GetPortfolioBreakdownUseCase
    let getPortfolioInsights:  GetPortfolioInsightsUseCase
    let rebalance:             RebalancePortfolioUseCase
    let getPortfolio:             GetPortfolioUseCase
    let getTransactionHistory:    GetTransactionHistoryUseCase
    let getUserProfile:           GetUserProfileUseCase
    let getSupportedCountries: GetSupportedCountriesUseCase
    let getTransferOptions:    GetTransferOptionsUseCase
    let validateKYC:           ValidateKYCStatusUseCase
    let initiateTransfer:      InitiateTransferUseCase
    let login:                 LoginUseCase
    let logout:                LogoutUseCase
    let restoreSession:        RestoreSessionUseCase
    let getCurrentUserID:      GetCurrentUserIDUseCase
    let getWatchlist:          GetWatchlistUseCase
    let addToWatchlist:        AddToWatchlistUseCase
    let removeFromWatchlist:   RemoveFromWatchlistUseCase
    let checkWatchlistStatus:  CheckWatchlistStatusUseCase
    let getTopMovers:             GetTopMoversUseCase
    let getTrending:              GetTrendingAssetsUseCase
    let getMarketNews:            GetMarketNewsUseCase
    let getPortfolioPerformance:  GetPortfolioPerformanceUseCase
    let getPortfolioHoldings:     GetPortfolioHoldingsUseCase

    init() {
        let useLiveRepositories = AppEnvironment.current != .development

        let market:    any MarketRepositoryProtocol
        let portfolio: any PortfolioRepositoryProtocol
        let order:     any OrderRepositoryProtocol
        let transfer:  any TransferRepositoryProtocol
        let auth:      any AuthRepositoryProtocol
        let watchlist: any WatchlistRepositoryProtocol

        if useLiveRepositories {
            let (apiClient, interceptor, keychain) = AppCompositionRoot.buildInfrastructure()
            market    = MarketRepositoryLive(apiClient: apiClient)
            portfolio = PortfolioRepositoryLive(apiClient: apiClient)
            order     = OrderRepositoryLive(apiClient: apiClient)
            transfer  = TransferRepositoryLive(apiClient: apiClient)
            auth      = AuthRepositoryLive(apiClient: apiClient, tokenInterceptor: interceptor, keychain: keychain)
            watchlist = WatchlistRepositoryLive(apiClient: apiClient)
        } else {
            // Los repos mock de órdenes y portafolio comparten un mismo MockBrokerStore
            // para que una compra / venta hecha en cualquier pantalla actualice el cash
            // y las posiciones en todos lados (mismo patrón que el CacheLayer.shared inyectado).
            let broker = MockBrokerStore.shared
            market    = MarketRepository()
            portfolio = PortfolioRepository(broker: broker)
            order     = OrderRepository(broker: broker)
            transfer  = TransferRepository()
            auth      = AuthRepository()
            watchlist = WatchlistRepository()
        }

        marketRepo    = market
        portfolioRepo = portfolio
        orderRepo     = order
        transferRepo  = transfer
        authRepo      = auth
        watchlistRepo = watchlist

        getInstruments        = GetInstrumentsUseCase(repository: market)
        getAssetDetail        = GetAssetDetailUseCase(repository: market)
        refreshMarket         = RefreshMarketDataUseCase(repository: market)
        placeOrder            = PlaceOrderUseCase(orderRepository: order, portfolioRepository: portfolio)
        calculatePL           = CalculatePLUseCase()
        getPortfolioBreakdown = GetPortfolioBreakdownUseCase()
        getPortfolioInsights  = GetPortfolioInsightsUseCase()
        rebalance             = RebalancePortfolioUseCase(portfolioRepository: portfolio)
        getPortfolio             = GetPortfolioUseCase(repository: portfolio)
        getTransactionHistory    = GetTransactionHistoryUseCase(repository: portfolio)
        getUserProfile           = GetUserProfileUseCase(repository: portfolio)
        getSupportedCountries = GetSupportedCountriesUseCase(repository: transfer)
        getTransferOptions    = GetTransferOptionsUseCase(repository: transfer)
        validateKYC           = ValidateKYCStatusUseCase(portfolioRepository: portfolio)
        initiateTransfer      = InitiateTransferUseCase(repository: transfer)
        login                 = LoginUseCase(repository: auth)
        logout                = LogoutUseCase(repository: auth)
        restoreSession        = RestoreSessionUseCase(repository: auth)
        getCurrentUserID      = GetCurrentUserIDUseCase(repository: auth)
        getWatchlist          = GetWatchlistUseCase(watchlistRepository: watchlist, marketRepository: market)
        addToWatchlist        = AddToWatchlistUseCase(repository: watchlist)
        removeFromWatchlist   = RemoveFromWatchlistUseCase(repository: watchlist)
        checkWatchlistStatus  = CheckWatchlistStatusUseCase(repository: watchlist)
        getTopMovers             = GetTopMoversUseCase()
        getTrending              = GetTrendingAssetsUseCase()
        getMarketNews            = GetMarketNewsUseCase()
        getPortfolioPerformance  = GetPortfolioPerformanceUseCase()
        getPortfolioHoldings     = GetPortfolioHoldingsUseCase()
    }

    private static func buildInfrastructure() -> (APIClient, TokenRefreshInterceptor, KeychainStore) {
        let keychain    = KeychainStore()
        let interceptor = TokenRefreshInterceptor(keychainStore: keychain)
        let builder     = RequestBuilder()
        let apiClient   = APIClient(requestBuilder: builder, tokenInterceptor: interceptor)
        return (apiClient, interceptor, keychain)
    }
}
