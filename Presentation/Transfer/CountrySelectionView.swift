//
//  CountrySelectionView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI
import FinCore

struct CountrySelectionView: View {

    @State private var viewModel: CountrySelectionViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: CountrySelectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                LoadingView(message: "Cargando países...")
            case .loaded:
                countryList
            case .failed:
                errorView(viewModel.loadState.userMessage)
            }
        }
        .navigationTitle(viewModel.flowType.navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ),
            prompt: "Buscar país"
        )
        .task { await viewModel.load() }
        // Navega a opciones cuando KYC está aprobado
        .onChange(of: viewModel.approvedCountry) { _, country in
            guard let country else { return }
            coordinator.transferNavPath.append(
                TransferRoute.options(country: country, flowType: viewModel.flowType)
            )
            viewModel.clearApprovedCountry()
        }
        // Muestra error de rechazo como alerta
        .alert(
            "Verificación rechazada",
            isPresented: Binding(
                get: { viewModel.rejectionReason != nil },
                set: { if !$0 { viewModel.clearRejection() } }
            ),
            presenting: viewModel.rejectionReason
        ) { _ in
            Button("Entendido", role: .cancel) { viewModel.clearRejection() }
        } message: { reason in
            Text(reason)
        }
        // Bottom sheet KYC
        .ifBottomSheet(
            isPresented: Binding(
                get: { viewModel.isKYCSheetPresented },
                set: { viewModel.isKYCSheetPresented = $0 }
            )
        ) {
            KYCValidationBottomSheet(
                status: viewModel.kycRequiredStatus,
                onDismiss: { viewModel.isKYCSheetPresented = false }
            )
        }
    }

    // MARK: - Lista de países

    private var countryList: some View {
        List(viewModel.filteredCountries) { country in
            CountryRowView(country: country) {
                Task { await viewModel.select(country) }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(.ifSecondary)
            Text(message)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .multilineTextAlignment(.center)
            Button("Reintentar") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
