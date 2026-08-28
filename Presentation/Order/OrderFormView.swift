//
//  OrderFormView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI
import FinCore
import FinUI

struct OrderFormView: View {

    @State private var viewModel: OrderFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: OrderFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle:
                Color.clear
            case .loading:
                LoadingView(message: "Cargando instrumento...")
            case .loaded:
                formContent
            case .failed:
                ErrorStateView(message: viewModel.loadState.userMessage) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle("Nueva Orden")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.submitState.succeededOrder) { _, order in
            if order != nil {
                // Se cierra tras un breve retardo para que el usuario vea el estado de éxito
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    dismiss()
                }
            }
        }
    }

    // MARK: - Formulario

    private var formContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let instrument = viewModel.instrument, let quote = viewModel.quote {
                    instrumentHeader(instrument: instrument, quote: quote)
                }
                sidePicker
                quantityField
                if viewModel.needsLimitPrice { limitPriceField }
                if viewModel.needsStopPrice  { stopPriceField  }
                orderTypePicker
                if let total = viewModel.estimatedTotal { estimatedTotalRow(total: total) }
                submitButton
                submitFeedback
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.ifBackground)
    }

    // MARK: - Encabezado de instrumento

    private func instrumentHeader(instrument: Instrument, quote: Quote) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(instrument.id)
                    .font(.ifTitle)
                Text(instrument.name)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                PriceChip(price: quote.price, currencyCode: instrument.currency.rawValue)
                PLBadge(absoluteValue: quote.change, percent: quote.changePercent)
            }
        }
        .padding(16)
        .background(Color.ifCard)
        .cornerRadius(12)
    }

    // MARK: - Selector de compra/venta

    private var sidePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Operación")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)

            HStack(spacing: 8) {
                sideButton(.buy,  label: "Comprar", color: .ifGreen)
                sideButton(.sell, label: "Vender",  color: .ifRed)
            }
        }
    }

    private func sideButton(_ side: OrderSide, label: String, color: Color) -> some View {
        let isSelected = viewModel.selectedSide == side
        return Button {
            viewModel.selectedSide = side
        } label: {
            Text(label)
                .font(.ifHeadline)
                .foregroundStyle(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
    }

    // MARK: - Tipo de orden

    private var orderTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipo de orden")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)

            Picker("Tipo", selection: $viewModel.selectedOrderType) {
                Text("Mercado").tag(OrderType.market)
                Text("Límite").tag(OrderType.limit)
                Text("Stop Loss").tag(OrderType.stopLoss)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Cantidad

    private var quantityField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cantidad")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)

            TextField("0", text: $viewModel.quantityText)
                .font(.ifPrice)
                .keyboardType(.decimalPad)
                .padding(14)
                .background(Color.ifCard)
                .cornerRadius(10)
        }
    }

    // MARK: - Campos de precio

    private var limitPriceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Precio límite (USD)")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
            TextField("0.00", text: $viewModel.limitPriceText)
                .font(.ifPrice)
                .keyboardType(.decimalPad)
                .padding(14)
                .background(Color.ifCard)
                .cornerRadius(10)
        }
    }

    private var stopPriceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Precio stop (USD)")
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
            TextField("0.00", text: $viewModel.stopPriceText)
                .font(.ifPrice)
                .keyboardType(.decimalPad)
                .padding(14)
                .background(Color.ifCard)
                .cornerRadius(10)
        }
    }

    // MARK: - Total estimado

    private func estimatedTotalRow(total: Decimal) -> some View {
        HStack {
            Text("Total estimado")
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)
            Spacer()
            PriceChip(price: total, currencyCode: "USD")
                .fontWeight(.semibold)
        }
        .padding(16)
        .background(Color.ifCard)
        .cornerRadius(10)
    }

    // MARK: - Envío

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            HStack(spacing: 8) {
                if viewModel.submitState.isPlacing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                }
                Text(viewModel.submitState.isPlacing ? "Enviando..." : buttonLabel)
                    .font(.ifHeadline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.canSubmit ? buttonColor : Color.gray.opacity(0.4))
            )
        }
        .disabled(!viewModel.canSubmit)
    }

    private var buttonLabel: String {
        viewModel.selectedSide == .buy ? "Comprar" : "Vender"
    }

    private var buttonColor: Color {
        viewModel.selectedSide == .buy ? .ifGreen : .ifRed
    }

    // MARK: - Feedback

    @ViewBuilder
    private var submitFeedback: some View {
        switch viewModel.submitState {
        case .success(let order):
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.ifGreen)
                Text("Orden \(order.status == .filled ? "ejecutada" : "enviada") correctamente")
                    .font(.ifBody)
                    .foregroundStyle(.ifGreen)
            }
            .padding(14)
            .background(Color.ifGreen.opacity(0.1))
            .cornerRadius(10)

        case .failure(let error):
            HStack(spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.ifRed)
                Text(errorMessage(error))
                    .font(.ifBody)
                    .foregroundStyle(.ifRed)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color.ifRed.opacity(0.1))
            .cornerRadius(10)

        default:
            EmptyView()
        }
    }

    private func errorMessage(_ error: Error) -> String {
        (error as? IFError)?.userMessage ?? error.localizedDescription
    }

    // MARK: - Error de carga

}

#Preview {
    NavigationStack {
        OrderFormView(
            viewModel: OrderFormViewModel(
                instrumentID: "AAPL",
                userID: PreviewData.userID,
                getAssetDetailUseCase: AppCompositionRoot.preview.getAssetDetail,
                placeOrderUseCase: AppCompositionRoot.preview.placeOrder
            )
        )
    }
}
