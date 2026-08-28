//
//  WatchlistView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct WatchlistView: View {

    @State private var viewModel: WatchlistViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: WatchlistViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                LoadingView(message: "Cargando lista...")
            case .loaded:
                if viewModel.isEmpty {
                    EmptyStateView(
                        icon: "star.circle",
                        title: "Sin activos seguidos",
                        subtitle: "Explora el mercado y añade activos a tu lista de seguimiento."
                    )
                } else {
                    listContent
                }
            case .failed:
                ErrorStateView(
                    message: viewModel.state.userMessage,
                    systemImage: "star.slash"
                ) {
                    Task { await viewModel.retry() }
                }
            }
        }
        .background(Color.ifNavy)
        .navigationTitle("Seguimiento")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Lista

    private var listContent: some View {
        List {
            if case .loaded(let entries) = viewModel.state {
                ForEach(entries) { entry in
                    Button {
                        coordinator.showWatchlistDetail(instrumentID: entry.instrument.id)
                    } label: {
                        WatchlistRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    if case .loaded(let currentEntries) = viewModel.state {
                        for index in indexSet {
                            let entry = currentEntries[index]
                            Task { await viewModel.remove(entry: entry) }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.ifNavy)
        .refreshable { await viewModel.load() }
    }
}

// MARK: - Fila

private struct WatchlistRowView: View {

    let entry: WatchlistEntry

    var body: some View {
        HStack(spacing: 12) {
            instrumentIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.instrument.id)
                    .font(.ifHeadline)
                    .lineLimit(1)
                Text(entry.instrument.name)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                PriceChip(
                    price: entry.quote.price,
                    currencyCode: entry.instrument.currency.rawValue
                )
                PLBadge(
                    absoluteValue: entry.quote.change,
                    percent: entry.quote.changePercent
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var instrumentIcon: some View {
        InstrumentLogoView(
            instrumentID: entry.instrument.id,
            instrumentType: entry.instrument.type,
            size: 44,
            tintColor: typeColor,
            logoScale: 0.50
        )
    }

    private var typeColor: Color { .ifBlue }
}
