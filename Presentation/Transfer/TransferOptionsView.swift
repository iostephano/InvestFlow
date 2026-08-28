//
//  TransferOptionsView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI
import FinCore

struct TransferOptionsView: View {

    @State private var viewModel: TransferOptionsViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: TransferOptionsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                LoadingView(message: "Cargando métodos...")
            case .loaded:
                optionsList
            case .failed:
                errorView(viewModel.loadState.userMessage)
            }
        }
        .navigationTitle(viewModel.flowType.title)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Lista de opciones

    private var optionsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                countryHeader
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                Divider()

                if viewModel.options.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.options) { option in
                            TransferOptionRowView(option: option) {
                                coordinator.transferNavPath.append(
                                    TransferRoute.enterAmount(
                                        country: viewModel.country,
                                        method: option,
                                        flowType: viewModel.flowType
                                    )
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)

                            if option.id != viewModel.options.last?.id {
                                Divider().padding(.leading, 78)
                            }
                        }
                    }
                }
            }
        }
        .background(.ifBackground)
    }

    // MARK: - Encabezado de país

    private var countryHeader: some View {
        HStack(spacing: 12) {
            Text(viewModel.country.flagEmoji)
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.country.name)
                    .font(.ifHeadline)
                Text("Selecciona cómo quieres \(viewModel.flowType == .deposit ? "depositar" : "retirar")")
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Estado vacío

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.ifSecondary)
            Text("Sin métodos disponibles")
                .font(.ifHeadline)
            Text("No hay métodos de \(viewModel.flowType == .deposit ? "depósito" : "retiro") para este país.")
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
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
            Button("Reintentar") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
