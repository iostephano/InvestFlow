//
//  MarketplaceView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct MarketplaceView: View {

    @State private var viewModel: MarketplaceViewModel
    @State private var moversTab: MoversTab = .gainers
    @State private var selectedNews: MarketNews? = nil
    @Environment(AppCoordinator.self) private var coordinator

    enum MoversTab { case gainers, losers }

    init(viewModel: MarketplaceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                loadingView
            case .loaded:
                mainContent
            case .failed:
                ErrorStateView(
                    message: viewModel.state.userMessage,
                    systemImage: "wifi.exclamationmark"
                ) {
                    Task { await viewModel.retry() }
                }
            }
        }
        .background(Color.ifNavy)
        .navigationTitle("Explorar")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
        .sheet(item: $selectedNews) { news in
            MarketNewsDetailView(news: news)
        }
    }

    // MARK: - Contenido principal

    private var mainContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                searchBar

                categoryRow
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                if viewModel.isFiltering {
                    filteredSection
                } else if let data = viewModel.data {
                    explorerSections(data: data)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.ifNavy)
        .refreshable { await viewModel.reload() }
    }

    // MARK: - Barra de búsqueda

    // Puente de Binding: @Observable + @State no expone $viewModel directamente —
    // Binding(get:set:) es el adaptador estándar acá.
    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        )
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Buscar acciones, ETFs, crypto...", text: searchTextBinding)
                .font(.ifBody)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .premiumSpecularBorder(cornerRadius: 12, lineWidth: 0.75)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Pills de categoría

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AssetCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Resultados filtrados / de búsqueda

    private var filteredSection: some View {
        VStack(spacing: 0) {
            if viewModel.filteredItems.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.filteredItems) { item in
                    Button {
                        coordinator.showAssetDetail(instrumentID: item.instrument.id)
                    } label: {
                        InstrumentRowView(instrument: item.instrument, quote: item.quote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 60)
                }
            }
        }
        .background(Color.ifCard)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Secciones del explorador

    @ViewBuilder
    private func explorerSections(data: MarketplaceViewModel.MarketplaceData) -> some View {
        sectionHeader("Top del día")
        moversSegmentedControl
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        moversScroll(data: data)
            .padding(.bottom, 24)

        sectionHeader("Más activos") {
            coordinator.navigateToFullMarket()
        }
        trendingScroll(items: data.trending)
            .padding(.bottom, 24)

        sectionHeader("Noticias del mercado")
        newsStack(items: data.news)
            .padding(.horizontal, 16)
    }

    // MARK: - Mayores movimientos

    private var moversSegmentedControl: some View {
        Picker("", selection: $moversTab) {
            Text("Ganadores").tag(MoversTab.gainers)
            Text("Perdedores").tag(MoversTab.losers)
        }
        .pickerStyle(.segmented)
    }

    private func moversScroll(data: MarketplaceViewModel.MarketplaceData) -> some View {
        let items = moversTab == .gainers ? data.topMovers.gainers : data.topMovers.losers
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    AssetCard(item: item) {
                        coordinator.showAssetDetail(instrumentID: item.instrument.id)
                    }
                    .ifScrollEdge()
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Tendencia

    private func trendingScroll(items: [MarketItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    AssetCard(item: item) {
                        coordinator.showAssetDetail(instrumentID: item.instrument.id)
                    }
                    .ifScrollEdge()
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Noticias

    private func newsStack(items: [MarketNews]) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, news in
                Button {
                    selectedNews = news
                } label: {
                    NewsCard(news: news)
                }
                .buttonStyle(.plain)
                .ifAppear(delay: Double(index) * 0.06)
            }
        }
    }

    // MARK: - Encabezado de sección

    private func sectionHeader(_ title: String, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.ifTitle)
            Spacer()
            if let action {
                Button("Ver todos", action: action)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifBlue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .padding(.top, 8)
    }

    // MARK: - Vacío / cargando / error

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.ifSecondary)
            Text("Sin resultados")
                .font(.ifHeadline)
            Text("Prueba con otro término o categoría")
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Cargando mercado...")
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}
