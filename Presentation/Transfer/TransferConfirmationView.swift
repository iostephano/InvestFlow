//
//  TransferConfirmationView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI
import FinCore

// MARK: - View

struct TransferConfirmationView: View {

    @State private var viewModel: TransferConfirmationViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: TransferConfirmationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                amountDisplay
                detailsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(.ifBackground)
        .navigationTitle("Confirmar")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) { confirmButton }
        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("Reintentar") { Task { await retryConfirm() } }
            Button("Cancelar", role: .cancel) { viewModel.clearError() }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    // MARK: - Visualización del monto

    private var amountDisplay: some View {
        VStack(spacing: 4) {
            Text(viewModel.request.amount.formatted(.currency(code: viewModel.request.currency)))
                .font(.system(size: 44, weight: .bold, design: .rounded))
            Text(viewModel.request.method.name)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Tarjeta de detalles

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Método", value: viewModel.request.method.name)
            Divider().padding(.leading, 16)
            detailRow(
                label: viewModel.request.method.feeIsPercentage
                    ? "Comisión"
                    : "Comisión fija",
                value: viewModel.feeAmount == .zero
                    ? "Gratis"
                    : viewModel.feeAmount.formatted(.currency(code: viewModel.request.currency)),
                valueColor: viewModel.feeAmount == .zero ? .ifGreen : .primary
            )
            Divider().padding(.leading, 16)
            detailRow(
                label: "Recibirás",
                value: viewModel.netAmount.formatted(.currency(code: viewModel.request.currency)),
                isBold: true
            )
            Divider().padding(.leading, 16)
            detailRow(label: "Tiempo estimado", value: viewModel.request.method.estimatedTime)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailRow(
        label: String,
        value: String,
        valueColor: Color = .primary,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)
            Spacer()
            Text(value)
                .font(isBold ? .ifHeadline : .ifBody)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Botón de confirmar

    private var confirmButton: some View {
        Button {
            Task { await submitConfirm() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Confirmar transferencia")
                        .font(.ifHeadline)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.blue, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.ifBackground)
    }

    // MARK: - Acciones

    private func submitConfirm() async {
        guard let result = await viewModel.confirm() else { return }
        coordinator.transferNavPath.append(TransferRoute.result(result))
    }

    private func retryConfirm() async {
        await submitConfirm()
    }

    private var errorMessage: String? {
        guard case .failed(let error) = viewModel.submitState else { return nil }
        return error.userMessage
    }
}
