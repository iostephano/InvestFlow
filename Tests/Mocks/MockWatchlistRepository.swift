//
//  MockWatchlistRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

struct MockWatchlistRepository: WatchlistRepositoryProtocol {

    var watchlistItems: [WatchlistItem] = []
    var inWatchlist: Bool = false
    var fetchError: Error? = nil    // affects: fetchWatchlist
    var removeError: Error? = nil   // affects: removeFromWatchlist
    var error: Error? = nil         // affects: addToWatchlist, isInWatchlist

    func fetchWatchlist(userID: String) async throws -> [WatchlistItem] {
        if let fetchError { throw fetchError }
        return watchlistItems
    }

    func addToWatchlist(userID: String, instrumentID: String) async throws {
        if let error { throw error }
    }

    func removeFromWatchlist(userID: String, instrumentID: String) async throws {
        if let removeError { throw removeError }
    }

    func isInWatchlist(userID: String, instrumentID: String) async throws -> Bool {
        if let error { throw error }
        return inWatchlist
    }
}
