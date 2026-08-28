//
//  TransferAmountView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI
import FinCore

struct TransferAmountView: View {

    @State private var viewModel: TransferAmountViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @FocusState private var isInputFocused: Bool

    init(viewModel: TransferAmountViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                methodHeader
                amountInputSection
                summarySection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(.ifBackground)
        .navigationTitle(viewModel.flowType == .deposit ? "Depositar" : "Retirar")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { isInputFocused = true }
        .safeAreaInset(edge: .bottom) { continueButton }
    }

    // MARK: - Encabezado del método

    private var methodHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: methodIcon)
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(methodColor, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.method.name)
                    .font(.ifHeadline)
                Text(viewModel.method.estimatedTime)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Entrada del monto

    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monto (USD)")
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.ifSecondary)

                TextField("0.00", text: $viewModel.amountText)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .focused($isInputFocused)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.5)
            )

            if let error = viewModel.validationError {
                Text(error)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifRed)
            } else {
                limitsHint
            }
        }
    }

    private var limitsHint: some View {
        HStack {
            Text("Mín: \(viewModel.method.minAmount.formatted(.currency(code: "USD")))")
            Spacer()
            Text("Máx: \(viewModel.method.maxAmount.formatted(.currency(code: "USD")))")
        }
        .font(.ifSubhead)
        .foregroundStyle(.ifSecondary)
    }

    // MARK: - Resumen

    @ViewBuilder
    private var summarySection: some View {
        if viewModel.amount != nil {
            VStack(spacing: 0) {
                summaryRow(
                    label: "Monto",
                    value: (viewModel.amount ?? .zero).formatted(.currency(code: "USD"))
                )
                Divider().padding(.leading, 16)
                summaryRow(
                    label: viewModel.method.feeIsPercentage
                        ? "Comisión (\(formatPercent(viewModel.method.fee)))"
                        : "Comisión fija",
                    value: viewModel.feeAmount == .zero
                        ? "Gratis"
                        : viewModel.feeAmount.formatted(.currency(code: "USD")),
                    valueColor: viewModel.feeAmount == .zero ? .ifGreen : .primary
                )
                Divider().padding(.leading, 16)
                summaryRow(
                    label: "Recibirás",
                    value: viewModel.netAmount.formatted(.currency(code: "USD")),
                    isBold: true
                )
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func summaryRow(
        label: String,
        value: String,
        valueColor: Color = .primary,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(isBold ? .ifHeadline : .ifBody)
                .foregroundStyle(isBold ? .primary : Color.ifSecondary)
            Spacer()
            Text(value)
                .font(isBold ? .ifHeadline : .ifBody)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Botón de continuar

    private var continueButton: some View {
        Button {
            guard let request = viewModel.buildRequest() else { return }
            coordinator.navigateToTransferConfirmation(request: request)
        } label: {
            Text("Continuar")
                .font(.ifHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.canContinue ? Color.blue : Color.gray.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .disabled(!viewModel.canContinue)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.ifBackground)
    }

    // MARK: - Auxiliares

    private var borderColor: Color {
        if let error = viewModel.validationError, !viewModel.amountText.isEmpty {
            return error.isEmpty ? .blue : .ifRed
        }
        return isInputFocused ? .blue : Color.gray.opacity(0.3)
    }

    private var methodIcon: String {
        switch viewModel.method.method {
        case .bankTransfer: return "building.columns"
        case .debitCard:    return "creditcard"
        case .wire:         return "globe"
        case .crypto:       return "bitcoinsign.circle"
        }
    }

    private var methodColor: Color {
        switch viewModel.method.method {
        case .bankTransfer: return .blue
        case .debitCard:    return .ifGreen
        case .wire:         return .ifRed
        case .crypto:       return .orange
        }
    }

    private func formatPercent(_ value: Decimal) -> String {
        let pct = value * 100
        return "\(pct)%"
    }
}
