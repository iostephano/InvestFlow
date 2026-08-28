//
//  SessionStore.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

/// Fuente de verdad del estado de autenticación.
/// Vive en InvestFlow como @State y se propaga por entorno.
@MainActor
@Observable
final class SessionStore {

    private static let avatarKey = "investflow_avatar_data"

    private(set) var session: AuthSession?
    /// JPEG thumbnail (~200 pt) del avatar elegido por el usuario. Nil = fallback iniciales.
    private(set) var avatarImageData: Data?

    var isAuthenticated: Bool { session != nil }
    var userID: String { session?.userID ?? "" }

    init() {
        avatarImageData = UserDefaults.standard.data(forKey: Self.avatarKey)
    }

    func signIn(_ session: AuthSession) {
        self.session = session
    }

    func signOut() {
        session = nil
        setAvatar(nil)
    }

    /// Actualiza el avatar en memoria y lo persiste en UserDefaults.
    func setAvatar(_ data: Data?) {
        avatarImageData = data
        if let data {
            UserDefaults.standard.set(data, forKey: Self.avatarKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.avatarKey)
        }
    }
}
