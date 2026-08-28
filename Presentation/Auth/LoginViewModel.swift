//
//  LoginViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    private(set) var state: LoadState<Void> = .idle

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var errorMessage: String? {
        if case .failed(let error) = state {
            return error.userMessage
        }
        return nil
    }

    var canLogin: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !isLoading
    }

    private let loginUseCase: LoginUseCase
    private let onSuccess: @MainActor (AuthSession) -> Void

    init(
        loginUseCase: LoginUseCase,
        onSuccess: @escaping @MainActor (AuthSession) -> Void
    ) {
        self.loginUseCase = loginUseCase
        self.onSuccess = onSuccess
    }

    func login() async {
        guard canLogin else { return }
        state = .loading
        do {
            let session = try await loginUseCase.execute(email: email, password: password)
            onSuccess(session)
            IFLogger.event("login_success", properties: ["method": "email"])
            state = .loaded(())
        } catch {
            IFLogger.error(error, context: "LoginViewModel.login")
            state = .failed(IFError.from(error))
        }
    }
}
