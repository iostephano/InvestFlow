//
//  TransactionHistoryViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class TransactionHistoryViewModel {

    // MARK: - Filtro

    enum Filter: String, CaseIterable, Identifiable {
        case all        = "Todos"
        case buy        = "Compra"
        case sell       = "Venta"
        case deposit    = "Depósito"
        case withdrawal = "Retiro"

        var id: Self { self }

        var types: [TransactionType]? {
            switch self {
            case .all:        return nil
            case .buy:        return [.buy]
            case .sell:       return [.sell]
            case .deposit:    return [.deposit]
            case .withdrawal: return [.withdrawal]
            }
        }
    }

    // MARK: - Estado

    private(set) var loadState: LoadState<[Transaction]> = .idle
    var selectedFilter: Filter = .all

    private var allTransactions: [Transaction] {
        guard case .loaded(let txs) = loadState else { return [] }
        return txs
    }

    var filteredTransactions: [Transaction] {
        guard let types = selectedFilter.types else { return allTransactions }
        return allTransactions.filter { types.contains($0.type) }
    }

    // Agrupado por mes, ordenado del más reciente al más antiguo
    var groupedByMonth: [(key: String, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            Self.monthKey(for: tx.executedAt)
        }
        return grouped
            .map { (key: $0.key, transactions: $0.value.sorted { $0.executedAt > $1.executedAt }) }
            .sorted { lhs, rhs in
                let lDate = Self.monthDate(from: lhs.key)
                let rDate = Self.monthDate(from: rhs.key)
                return (lDate ?? .distantPast) > (rDate ?? .distantPast)
            }
    }

    var isEmpty: Bool { filteredTransactions.isEmpty }

    // MARK: - Dependencias

    private let userID: String
    private let getTransactionHistoryUseCase: GetTransactionHistoryUseCase

    init(userID: String, getTransactionHistoryUseCase: GetTransactionHistoryUseCase) {
        self.userID = userID
        self.getTransactionHistoryUseCase = getTransactionHistoryUseCase
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading
        do {
            let txs = try await getTransactionHistoryUseCase.execute(userID: userID)
            loadState = .loaded(txs.sorted { $0.executedAt > $1.executedAt })
        } catch {
            IFLogger.error(error, context: "TransactionHistoryViewModel.load")
            loadState = .failed(IFError.from(error))
        }
    }

    func retry() async {
        loadState = .idle
        await load()
    }

    func reload() async {
        loadState = .idle
        do {
            let txs = try await getTransactionHistoryUseCase.reload(userID: userID)
            loadState = .loaded(txs.sorted { $0.executedAt > $1.executedAt })
        } catch {
            IFLogger.error(error, context: "TransactionHistoryViewModel.reload")
            loadState = .failed(IFError.from(error))
        }
    }

    // MARK: - Auxiliares de formato

    static func monthKey(for date: Date) -> String {
        monthFormatter.string(from: date)
    }

    private static func monthDate(from key: String) -> Date? {
        monthFormatter.date(from: key)
    }

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "es_419")
        return f
    }()
}
