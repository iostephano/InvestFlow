//
//  ProfileViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Estado

    private(set) var loadState: LoadState<UserProfile> = .idle
    private(set) var isLoggingOut: Bool = false
    private(set) var logoutError: String? = nil

    // MARK: - Biometría

    var isBiometricsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometrics_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometrics_enabled") }
    }

    let biometryType: BiometryType

    var biometryLabel: String {
        switch biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none:    return "Biometría"
        }
    }

    var isBiometricsAvailable: Bool { biometryType != .none }

    // MARK: - Derivadas

    var profile: UserProfile? {
        guard case .loaded(let p) = loadState else { return nil }
        return p
    }

    // MARK: - Dependencias

    private let userID: String
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let logoutUseCase: LogoutUseCase
    private let sessionStore: SessionStore
    private let biometricsHelper: BiometricsHelper

    init(
        userID: String,
        getUserProfileUseCase: GetUserProfileUseCase,
        logoutUseCase: LogoutUseCase,
        sessionStore: SessionStore,
        biometricsHelper: BiometricsHelper = BiometricsHelper()
    ) {
        self.userID               = userID
        self.getUserProfileUseCase = getUserProfileUseCase
        self.logoutUseCase        = logoutUseCase
        self.sessionStore         = sessionStore
        self.biometricsHelper     = biometricsHelper
        self.biometryType         = biometricsHelper.biometryType
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading
        do {
            let profile = try await getUserProfileUseCase.execute(userID: userID)
            loadState = .loaded(profile)
        } catch {
            IFLogger.error(error, context: "ProfileViewModel.load")
            loadState = .failed(IFError.from(error))
        }
    }

    func toggleBiometrics() async {
        if isBiometricsEnabled {
            isBiometricsEnabled = false
        } else {
            do {
                try await biometricsHelper.authenticate(reason: "Confirma tu identidad para habilitar \(biometryLabel)")
                isBiometricsEnabled = true
            } catch {
                IFLogger.error(error, context: "ProfileViewModel.toggleBiometrics")
            }
        }
    }

    func logout() async {
        isLoggingOut = true
        logoutError  = nil
        defer { isLoggingOut = false }
        do {
            try await logoutUseCase.execute()
            sessionStore.signOut()
        } catch {
            IFLogger.error(error, context: "ProfileViewModel.logout")
            logoutError = IFError.from(error).userMessage
        }
    }
}
