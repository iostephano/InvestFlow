//
//  HomeViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - Tipo de acción rápida

    enum QuickActionType: CaseIterable, Identifiable {
        case deposit
        case withdraw
        case invest

        var id: Self { self }

        var title: String {
            switch self {
            case .deposit:  return "Depositar"
            case .withdraw: return "Retirar"
            case .invest:   return "Invertir"
            }
        }

        var icon: String {
            switch self {
            case .deposit:  return "arrow.down.circle.fill"
            case .withdraw: return "arrow.up.circle.fill"
            case .invest:   return "chart.line.uptrend.xyaxis.circle.fill"
            }
        }
    }

    // MARK: - Tarjeta promocional

    struct PromoCard: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let theme: Theme

        enum Theme { case blue, green, purple }

        static let defaultCards: [PromoCard] = [
            PromoCard(
                id: "promo_1",
                title: "Diversifica tu portafolio",
                subtitle: "Accede a más de 100 ETFs globales",
                theme: .blue
            ),
            PromoCard(
                id: "promo_2",
                title: "Crypto sin límites",
                subtitle: "Opera BTC y ETH en tiempo real",
                theme: .green
            ),
            PromoCard(
                id: "promo_3",
                title: "Inversión automática",
                subtitle: "Ahorro programado desde $10",
                theme: .purple
            ),
        ]
    }

    // MARK: - Estado

    private(set) var userName: String = ""
    private(set) var buyingPower: Decimal = 0
    private(set) var loadState: LoadState<Void> = .idle
    private(set) var watchlistSnapshot: [WatchlistEntry] = []
    let quickActions: [QuickActionType] = QuickActionType.allCases
    let promotionalCards: [PromoCard] = PromoCard.defaultCards

    // MARK: - Dependencias

    private let userID: String
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let getWatchlistUseCase: GetWatchlistUseCase

    init(
        userID: String,
        getUserProfileUseCase: GetUserProfileUseCase,
        getWatchlistUseCase: GetWatchlistUseCase
    ) {
        self.userID = userID
        self.getUserProfileUseCase = getUserProfileUseCase
        self.getWatchlistUseCase   = getWatchlistUseCase
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading

        // Ambas tareas corren concurrentemente — latencia total = max(perfil, watchlist).
        async let profileTask   = getUserProfileUseCase.execute(userID: userID)
        async let watchlistTask = getWatchlistUseCase.execute(userID: userID)

        // El perfil es crítico: si falla, Home pasa a estado de error.
        do {
            let profile = try await profileTask
            userName    = profile.firstName
            buyingPower = profile.cashBalance
            loadState   = .loaded(())
        } catch {
            IFLogger.error(error, context: "HomeViewModel.load")
            loadState = .failed(IFError.from(error))
        }

        // La watchlist no es crítica: si falla, el snapshot queda vacío, nunca bloquea Home.
        // Se espera después del perfil para respetar la concurrencia estructurada (la tarea hija no debe escaparse).
        watchlistSnapshot = (try? await watchlistTask) ?? []
    }

    func retry() async {
        loadState = .idle
        await load()
    }
}
