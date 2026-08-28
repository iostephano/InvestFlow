//
//  KeychainStore.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import Security

/// Claves de Keychain para los tokens de InvestFlow.
/// enum caseless: no instanciable, sus static let no tienen aislamiento de actor.
public nonisolated enum KeychainTokenKeys {
    static let accessToken  = "investflow.access_token"
    static let refreshToken = "investflow.refresh_token"
}

public enum KeychainError: Error, Sendable {
    case itemNotFound
    case invalidData
    case unexpectedStatus(OSStatus)
}

// MARK: - Protocolo

/// Contrato de acceso a Keychain. Permite inyección de mocks en tests.
public protocol KeychainStoreProtocol: Sendable {
    nonisolated func loadString(for key: String) throws -> String
    nonisolated func saveString(_ value: String, for key: String) throws
    nonisolated func delete(for key: String) throws
}

/// Abstracción thread-safe sobre Keychain Services.
/// `final class @unchecked Sendable`: Security framework garantiza su propia seguridad
/// de hilos a nivel de OS; un actor añadiría overhead sin beneficio de corrección.
public final class KeychainStore: KeychainStoreProtocol, @unchecked Sendable {

    private let service: String

    public nonisolated init(service: String = "com.investflow.app") {
        self.service = service
    }

    // MARK: - Datos crudos

    public nonisolated func save(_ data: Data, for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass:                  kSecClassGenericPassword,
            kSecAttrService:            service,
            kSecAttrAccount:            key,
            kSecValueData:              data,
            kSecAttrAccessible:         kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let search: [CFString: Any] = [
                kSecClass:       kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: key
            ]
            let update: [CFString: Any] = [kSecValueData: data]
            let updateStatus = SecItemUpdate(search as CFDictionary, update as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    public nonisolated func load(for key: String) throws -> Data {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw status == errSecItemNotFound ? KeychainError.itemNotFound : KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data else { throw KeychainError.invalidData }
        return data
    }

    public nonisolated func delete(for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Conveniencia para String

    public nonisolated func saveString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else { throw KeychainError.invalidData }
        try save(data, for: key)
    }

    public nonisolated func loadString(for key: String) throws -> String {
        let data = try load(for: key)
        guard let string = String(data: data, encoding: .utf8) else { throw KeychainError.invalidData }
        return string
    }
}
