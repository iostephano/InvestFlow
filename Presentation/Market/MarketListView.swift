//
//  MarketListView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore
import FinUI

struct MarketListView: View {
    
    @State private var viewModel: MarketListViewModel
    
    init(viewModel: MarketListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        content
            .navigationTitle("Mercado")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                prompt: "Buscar acciones, ETFs, crypto..."
            )
            .task {
                await viewModel.loadInstruments()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
            
        case .loading:
            loadingView
            
        case .loaded:
            if viewModel.filteredItems.isEmpty {
                EmptyStateView(
                    icon: "chart.line.downtrend.xyaxis",
                    title: "No hay instrumentos",
                    subtitle: viewModel.searchText.isEmpty
                        ? "No hay instrumentos disponibles en este momento."
                        : "No se encontraron resultados para \"\(viewModel.searchText)\"."
                )
            } else {
                instrumentsList
            }
            
        case .failed:
            errorView(viewModel.state.userMessage)
        }
    }
    
    // MARK: - Subvistas
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando mercado...")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var instrumentsList: some View {
        List(viewModel.filteredItems, id: \.0.id) { instrument, quote in
            NavigationLink(value: IFRoute.assetDetail(instrumentID: instrument.id)) {
                InstrumentRowView(instrument: instrument, quote: quote)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable { await viewModel.reload() }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Reintentar") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Fila de instrumento

struct InstrumentRowView: View {
    
    let instrument: Instrument
    let quote: Quote
    
    // `static`: se crea una sola vez durante la vida del proceso, no en cada render/reciclado de fila.
    // `currencyCode` se reasigna en cada llamada porque varía por instrumento; es seguro porque
    // los miembros de View están implícitamente aislados a MainActor (un solo hilo, sin reentrada).
    @MainActor private static let priceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    @MainActor private static let changeFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.positivePrefix = "+"
        return f
    }()

    private var priceFormatted: String {
        Self.priceFormatter.currencyCode = instrument.currency.rawValue
        return Self.priceFormatter.string(from: quote.price as NSDecimalNumber) ?? "-"
    }

    private var changeFormatted: String {
        // Dividimos por 100 porque changePercent ya está en % (ej: 2.30 = 2.30%)
        let value = (quote.changePercent / 100) as NSDecimalNumber
        return Self.changeFormatter.string(from: value) ?? "-"
    }
    
    var body: some View {
        HStack(spacing: 12) {

            instrumentIcon

            VStack(alignment: .leading, spacing: 2) {
                Text(instrument.id)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(instrument.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(priceFormatted)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                
                Text(changeFormatted)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(quote.isPositive ? .green : .red)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 4)
    }
    
    private var instrumentIcon: some View {
        InstrumentLogoView(
            instrumentID: instrument.id,
            instrumentType: instrument.type,
            size: 44,
            tintColor: iconColor,
            backgroundOpacity: 0.15,
            logoScale: 0.55
        )
    }

    private var iconColor: Color { .ifBlue }
}

// MARK: - Vista previa

#Preview {
    NavigationStack {
        MarketListView(
            viewModel: MarketListViewModel(
                getInstrumentsUseCase: AppCompositionRoot.preview.getInstruments
            )
        )
    }
}
