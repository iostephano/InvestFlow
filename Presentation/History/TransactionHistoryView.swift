//
//  TransactionHistoryView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI
import FinCore

struct TransactionHistoryView: View {

    @State private var viewModel: TransactionHistoryViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: TransactionHistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                LoadingView(message: "Cargando historial...")
            case .loaded:
                loadedContent
            case .failed:
                errorView(viewModel.loadState.userMessage)
            }
        }
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Contenido cargado

    private var loadedContent: some View {
        VStack(spacing: 0) {
            filterBar
            if viewModel.isEmpty {
                emptyState
            } else {
                transactionList
            }
        }
        .background(.ifBackground)
    }

    // MARK: - Barra de filtros

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionHistoryViewModel.Filter.allCases) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.background)
    }

    private func filterChip(_ filter: TransactionHistoryViewModel.Filter) -> some View {
        let isSelected = viewModel.selectedFilter == filter
        return Button {
            viewModel.selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.ifSubhead)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected ? Color.blue : Color(.systemGray5),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lista de transacciones

    private var transactionList: some View {
        List {
            ForEach(viewModel.groupedByMonth, id: \.key) { group in
                Section(header: monthHeader(group.key)) {
                    ForEach(group.transactions, id: \.id) { tx in
                        TransactionRow(transaction: tx)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.reload() }
    }

    private func monthHeader(_ key: String) -> some View {
        Text(formattedMonth(key))
            .font(.ifSubhead)
            .fontWeight(.semibold)
            .foregroundStyle(.ifSecondary)
            .textCase(nil)
    }

    // static: se crea una sola vez durante la vida del proceso, no en cada render.
    @MainActor private static let monthKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "es_419")
        return f
    }()

    @MainActor private static let monthDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "es_419")
        return f
    }()

    private func formattedMonth(_ key: String) -> String {
        guard let date = Self.monthKeyFormatter.date(from: key) else { return key }
        return Self.monthDisplayFormatter.string(from: date).capitalized
    }

    // MARK: - Estado vacío

    private var emptyState: some View {
        EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: "Sin transacciones",
            subtitle: "No hay transacciones para el filtro seleccionado."
        )
        .padding(.top, 60)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.ifRed)
            Text(message)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Reintentar") { Task { await viewModel.retry() } }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

// MARK: - TransactionRow

private struct TransactionRow: View {

    let transaction: FinCore.Transaction

    var body: some View {
        HStack(spacing: 14) {
            iconView
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.ifBody)
                Text(subtitle)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(amountText)
                    .font(.ifBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor)
                Text(transaction.executedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.ifSubhead)
                    .foregroundStyle(.ifTertiary)
            }
        }
        .padding(.vertical, 12)
    }

    private var iconView: some View {
        Image(systemName: typeIcon)
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(iconColor, in: RoundedRectangle(cornerRadius: 10))
    }

    private var title: String {
        if let id = transaction.instrumentID { return id }
        switch transaction.type {
        case .deposit:    return "Depósito"
        case .withdrawal: return "Retiro"
        case .dividend:   return "Dividendo"
        case .fee:        return "Comisión"
        default:          return "Transacción"
        }
    }

    private var subtitle: String {
        switch transaction.type {
        case .buy:        return "Compra"
        case .sell:       return "Venta"
        case .deposit:    return "Depósito"
        case .withdrawal: return "Retiro"
        case .dividend:   return "Dividendo"
        case .fee:        return "Comisión"
        }
    }

    private var amountText: String {
        let sign = transaction.netAmount >= 0 ? "+" : ""
        return "\(sign)\(transaction.netAmount.formatted(.currency(code: transaction.currency.rawValue)))"
    }

    private var amountColor: Color {
        transaction.netAmount >= 0 ? .ifGreen : .ifRed
    }

    private var typeIcon: String {
        switch transaction.type {
        case .buy:        return "arrow.down.circle"
        case .sell:       return "arrow.up.circle"
        case .deposit:    return "plus.circle"
        case .withdrawal: return "minus.circle"
        case .dividend:   return "banknote"
        case .fee:        return "percent"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .buy:        return .blue
        case .sell:       return .ifGreen
        case .deposit:    return .ifGreen
        case .withdrawal: return .ifRed
        case .dividend:   return .purple
        case .fee:        return .ifTertiary
        }
    }
}
