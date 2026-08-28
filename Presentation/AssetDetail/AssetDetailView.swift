//
//  AssetDetailView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore
import FinUI

struct AssetDetailView: View {

    @State private var viewModel: AssetDetailViewModel
    @State private var selectedPeriod: ChartPeriod = .day

    init(viewModel: AssetDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                LoadingView(message: "Cargando activo...")
            case .loaded:
                scrollContent
            case .failed:
                ErrorStateView(message: viewModel.state.userMessage) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle(viewModel.instrumentID)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleWatchlist() }
                } label: {
                    if viewModel.isUpdatingWatchlist {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Image(systemName: viewModel.isInWatchlist ? "star.fill" : "star")
                            .contentTransition(.symbolEffect(.replace))
                            .foregroundStyle(viewModel.isInWatchlist ? Color.yellow : Color.primary)
                    }
                }
                .disabled(viewModel.isUpdatingWatchlist || viewModel.instrument == nil)

                if viewModel.isRefreshing {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Button {
                        Task { await viewModel.refreshQuote() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Contenido scrollable

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let instrument = viewModel.instrument, let quote = viewModel.quote {
                    headerSection(instrument: instrument, quote: quote)
                    chartSection(quote: quote)
                    statsSection(instrument: instrument, quote: quote)
                    actionButtons(instrumentID: instrument.id)
                }
            }
        }
        .background(Color.ifBackground)
    }

    // MARK: - Encabezado

    private func headerSection(instrument: Instrument, quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(instrument.name)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)

            PriceChip(price: quote.price, currencyCode: instrument.currency.rawValue, size: .large)

            HStack(spacing: 8) {
                PLBadge(absoluteValue: quote.change, percent: quote.changePercent)

                Text(instrument.exchange)
                    .font(.ifCaption)
                    .foregroundStyle(.ifTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.ifCard)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Gráfico

    private func chartSection(quote: Quote) -> some View {
        VStack(spacing: 12) {
            CandlestickChartView(quote: quote, period: selectedPeriod)
                .frame(height: 200)
                .padding(.horizontal, 4)

            Picker("Período", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.ifCard)
    }

    // MARK: - Estadísticas

    private func statsSection(instrument: Instrument, quote: Quote) -> some View {
        VStack(spacing: 0) {
            statRow(label: "Variación", value: formatChange(quote))
            Divider().padding(.leading, 16)
            statRow(label: "Volumen", value: formatVolume(quote.volume))
            Divider().padding(.leading, 16)
            statRow(label: "Moneda", value: instrument.currency.rawValue)
            Divider().padding(.leading, 16)
            statRow(label: "Mercado", value: instrument.exchange)
        }
        .background(Color.ifCard)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ifBody)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.ifBody)
                .fontWeight(.medium)
                .foregroundStyle(.ifSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Acciones

    private func actionButtons(instrumentID: String) -> some View {
        HStack(spacing: 12) {
            NavigationLink(value: IFRoute.orderForm(instrumentID: instrumentID, side: .buy)) {
                Text("Comprar")
                    .font(.ifHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ifGreen)
                    .cornerRadius(14)
            }
            NavigationLink(value: IFRoute.orderForm(instrumentID: instrumentID, side: .sell)) {
                Text("Vender")
                    .font(.ifHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ifRed)
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    // MARK: - Formateadores

    // static: se crea una sola vez durante la vida del proceso, no en cada render.
    @MainActor private static let changeFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.positivePrefix = "+"
        return f
    }()

    @MainActor private static let volumeFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    private func formatChange(_ quote: Quote) -> String {
        let value = quote.change as NSDecimalNumber
        return Self.changeFormatter.string(from: value) ?? "-"
    }

    private func formatVolume(_ volume: Int64) -> String {
        Self.volumeFormatter.string(from: NSNumber(value: volume)) ?? "-"
    }
}

#Preview {
    NavigationStack {
        AssetDetailView(
            viewModel: AssetDetailViewModel(
                instrumentID: "AAPL",
                userID: "preview",
                getAssetDetailUseCase: AppCompositionRoot.preview.getAssetDetail,
                refreshMarketDataUseCase: AppCompositionRoot.preview.refreshMarket,
                addToWatchlistUseCase: AppCompositionRoot.preview.addToWatchlist,
                removeFromWatchlistUseCase: AppCompositionRoot.preview.removeFromWatchlist,
                checkWatchlistStatusUseCase: AppCompositionRoot.preview.checkWatchlistStatus
            )
        )
    }
}
