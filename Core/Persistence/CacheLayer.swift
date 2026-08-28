//
//  CacheLayer.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Cache genérica con TTL. Actor garantiza thread-safety en Swift 6.2.
/// Usada por repositorios para evitar requests redundantes.
public actor CacheLayer {

    private struct Entry: Sendable {
        let value: any Sendable
        let expiresAt: Date

        var isExpired: Bool { Date() > expiresAt }
    }

    public static let shared = CacheLayer()

    private var storage: [String: Entry] = [:]

    private init() {}

    // MARK: - Escritura

    public func set<T: Sendable>(_ value: T, for key: String, ttl: TimeInterval) {
        storage[key] = Entry(value: value, expiresAt: Date().addingTimeInterval(ttl))
    }

    // MARK: - Lectura

    public func get<T: Sendable>(_ key: String) -> T? {
        guard let entry = storage[key] else { return nil }
        if entry.isExpired {
            storage.removeValue(forKey: key)
            return nil
        }
        return entry.value as? T
    }

    // MARK: - Invalidación

    public func remove(for key: String) {
        storage.removeValue(forKey: key)
    }

    public func removeAll() {
        storage.removeAll()
    }

    public func contains(_ key: String) -> Bool {
        guard let entry = storage[key] else { return false }
        if entry.isExpired {
            storage.removeValue(forKey: key)
            return false
        }
        return true
    }
}
