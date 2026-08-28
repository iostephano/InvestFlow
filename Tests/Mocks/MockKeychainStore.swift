//
//  MockKeychainStore.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
@testable import InvestFlow

final class MockKeychainStore: KeychainStoreProtocol, @unchecked Sendable {
    private var storage: [String: String] = [:]
    var shouldThrowOnSave = false

    func loadString(for key: String) throws -> String {
        guard let value = storage[key] else { throw KeychainError.itemNotFound }
        return value
    }

    func saveString(_ value: String, for key: String) throws {
        if shouldThrowOnSave { throw KeychainError.unexpectedStatus(-1) }
        storage[key] = value
    }

    func delete(for key: String) throws {
        storage.removeValue(forKey: key)
    }
}
