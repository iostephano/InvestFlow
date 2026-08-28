//
//  MockPortfolioRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

struct MockPortfolioRepository: PortfolioRepositoryProtocol {

    let portfolio: Portfolio
    let positions: [Position]
    let transactions: [Transaction]
    let cashBalance: Decimal
    let userProfile: UserProfile
    let error: Error?

    init(
        portfolio: Portfolio = .stub(),
        positions: [Position] = [],
        transactions: [Transaction] = [],
        cashBalance: Decimal = 10_000,
        userProfile: UserProfile = .stub(),
        error: Error? = nil
    ) {
        self.portfolio = portfolio
        self.positions = positions
        self.transactions = transactions
        self.cashBalance = cashBalance
        self.userProfile = userProfile
        self.error = error
    }

    func fetchPortfolio(for userID: String) async throws -> Portfolio {
        if let error { throw error }
        return portfolio
    }

    func fetchPositions(for userID: String) async throws -> [Position] {
        if let error { throw error }
        return positions
    }

    func fetchTransactions(for userID: String, limit: Int) async throws -> [Transaction] {
        if let error { throw error }
        return transactions
    }

    func fetchCashBalance(for userID: String) async throws -> Decimal {
        if let error { throw error }
        return cashBalance
    }

    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        if let error { throw error }
        return userProfile
    }

    func invalidateCache(for userID: String) async {}
}
