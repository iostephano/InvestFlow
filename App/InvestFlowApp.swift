//
//  InvestFlowApp.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore

@main
struct InvestFlowApp: App {

    @State private var composition = AppCompositionRoot()
    @State private var coordinator = AppCoordinator()
    @State private var sessionStore = SessionStore()
    @State private var isBootstrapped = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !isBootstrapped {
                    SplashView()
                        .task {
                            async let sessionResult = composition.restoreSession.execute()
                            async let minimumDelay: Void = Task.sleep(for: .seconds(2))
                            if let session = try? await sessionResult {
                                sessionStore.signIn(session)
                            }
                            try? await minimumDelay
                            isBootstrapped = true
                        }
                } else if sessionStore.isAuthenticated {
                    RootTabView(coordinator: coordinator, sessionStore: sessionStore)
                } else {
                    LoginView(
                        viewModel: LoginViewModel(
                            loginUseCase: composition.login,
                            onSuccess: { session in sessionStore.signIn(session) }
                        )
                    )
                }
            }
            .environment(composition)
            .onChange(of: sessionStore.isAuthenticated) { _, isAuth in
                if !isAuth { coordinator.performLogout() }
            }
        }
    }
}
