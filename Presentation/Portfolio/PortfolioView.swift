//
//  PortfolioView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore
import FinUI

struct PortfolioView: View {

    @State private var viewModel: PortfolioViewModel
    @State private var selectedTab: PortfolioViewModel.Tab = .overview
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: PortfolioViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                LoadingView(message: "Cargando portafolio...")
            case .loaded:
                portfolioContent
            case .failed:
                ErrorStateView(
                    message: viewModel.state.userMessage,
                    systemImage: "briefcase.slash"
                ) {
                    Task { await viewModel.retry() }
                }
            }
        }
        .background(Color.ifNavy)
        .navigationTitle("Mi Portafolio")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Contenedor de tabs

    private var portfolioContent: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Portafolio").tag(PortfolioViewModel.Tab.overview)
                Text("Activos").tag(PortfolioViewModel.Tab.assets)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            ScrollView {
                if selectedTab == .overview {
                    overviewContent
                        .transition(.opacity.combined(with: .offset(y: 6)))
                } else {
                    assetsContent
                        .transition(.opacity.combined(with: .offset(y: 6)))
                }
            }
            .background(Color.ifNavy)
            .animation(IFMotion.snap, value: selectedTab)
            .refreshable { await viewModel.reload() }
        }
        .background(Color.ifNavy)
    }

    // MARK: - Tab de resumen

    private var overviewContent: some View {
        VStack(spacing: 16) {
            if let summary = viewModel.plSummary {
                summaryCard(summary: summary)
                    .ifAppear(delay: 0)
            }
            if let breakdown = viewModel.breakdown {
                PortfolioChartView(breakdown: breakdown)
                    .padding(.horizontal, 16)
                    .ifAppear(delay: 0.07)
                AssetBreakdownBar(breakdown: breakdown)
                    .padding(.horizontal, 16)
                    .ifAppear(delay: 0.10)
            }
            if let insights = viewModel.insights {
                PortfolioInsightCard(insights: insights) { portfolio in
                    coordinator.showPortfolioDetail(portfolio)
                }
                .padding(.horizontal, 16)
                .ifAppear(delay: 0.13)
            }
            if !viewModel.rebalanceSuggestions.isEmpty {
                rebalanceSuggestionsSection
                    .ifAppear(delay: 0.16)
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Tab de activos

    private var assetsContent: some View {
        VStack(spacing: 16) {
            if let portfolio = viewModel.portfolio {
                if portfolio.positions.isEmpty {
                    EmptyStateView(
                        icon: "briefcase",
                        title: "Sin posiciones",
                        subtitle: "Aún no tienes activos en tu portafolio.",
                        ctaTitle: "Empieza a invertir"
                    ) {
                        coordinator.navigateToFullMarket()
                    }
                    .padding(.top, 40)
                } else {
                    positionsSection(portfolio: portfolio)
                }
            }
            if !viewModel.transactions.isEmpty {
                transactionsSection
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Tarjeta de resumen

    private func summaryCard(summary: PLSummary) -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Valor total")
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                PriceChip(price: summary.totalPortfolioValue, currencyCode: "USD", size: .large)
            }

            HStack(spacing: 32) {
                VStack(spacing: 2) {
                    Text("Invertido")
                        .font(.ifCaption)
                        .foregroundStyle(.ifSecondary)
                    PriceChip(price: summary.totalMarketValue, currencyCode: "USD")
                }
                VStack(spacing: 2) {
                    Text("Efectivo")
                        .font(.ifCaption)
                        .foregroundStyle(.ifSecondary)
                    PriceChip(price: summary.cashBalance, currencyCode: "USD")
                }
            }

            PLBadge(
                absoluteValue: summary.totalUnrealizedPL,
                percent:       summary.totalUnrealizedPLPercent
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .ifSurface(.opaque, radius: IFRadius.md)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Posiciones

    private func positionsSection(portfolio: Portfolio) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Posiciones")
                .font(.ifHeadline)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(portfolio.positions.enumerated()), id: \.element.id) { index, position in
                    PositionRowView(position: position)
                        .ifAppear(delay: Double(index) * 0.05)
                    if position.id != portfolio.positions.last?.id {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .ifSurface(.opaque, radius: IFRadius.sm, shadow: IFShadow.none)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Transacciones

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Actividad reciente")
                .font(.ifHeadline)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                let recent = Array(viewModel.transactions.prefix(10))
                ForEach(recent) { transaction in
                    TransactionRowView(transaction: transaction)
                    if transaction.id != recent.last?.id {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .ifSurface(.opaque, radius: IFRadius.sm, shadow: IFShadow.none)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Sugerencias de rebalanceo

    private var rebalanceSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sugerencias de rebalanceo")
                .font(.ifHeadline)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(viewModel.rebalanceSuggestions, id: \.instrumentID) { suggestion in
                    RebalanceSuggestionRow(suggestion: suggestion)
                    if suggestion.instrumentID != viewModel.rebalanceSuggestions.last?.instrumentID {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .ifSurface(.opaque, radius: IFRadius.sm, shadow: IFShadow.none)
            .padding(.horizontal, 16)
        }
    }

}

#Preview {
    NavigationStack {
        PortfolioView(
            viewModel: PortfolioViewModel(
                userID: PreviewData.userID,
                getPortfolioUseCase: AppCompositionRoot.preview.getPortfolio,
                getTransactionHistoryUseCase: AppCompositionRoot.preview.getTransactionHistory,
                rebalanceUseCase: AppCompositionRoot.preview.rebalance,
                calculatePLUseCase: AppCompositionRoot.preview.calculatePL,
                getBreakdownUseCase: AppCompositionRoot.preview.getPortfolioBreakdown,
                getInsightsUseCase: AppCompositionRoot.preview.getPortfolioInsights
            )
        )
        .environment(AppCoordinator())
    }
}
