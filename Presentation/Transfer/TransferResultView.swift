//
//  TransferResultView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinUI
import FinCore

struct TransferResultView: View {

    let result: TransferResult
    @Environment(AppCoordinator.self) private var coordinator

    private var isSuccess: Bool {
        if case .completed = result.status { return true }
        if case .processing = result.status { return true }
        if case .pending = result.status { return true }
        return false
    }

    private var statusLabel: String {
        switch result.status {
        case .pending:         return "Pendiente"
        case .processing:      return "En proceso"
        case .completed:       return "Completada"
        case .failed(let msg): return msg
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            statusIcon
                .padding(.bottom, 24)

            Text(isSuccess ? "¡Transferencia enviada!" : "Error en la transferencia")
                .font(.ifTitle)
                .multilineTextAlignment(.center)

            Text(statusLabel)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
                .padding(.top, 4)

            if isSuccess {
                successDetails
                    .padding(.top, 32)
            }

            Spacer()
            actionButtons
        }
        .padding(.horizontal, 24)
        .background(.ifBackground)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Icono de estado

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(isSuccess ? Color.ifGreen.opacity(0.15) : Color.ifRed.opacity(0.15))
                .frame(width: 100, height: 100)
            Image(systemName: isSuccess ? "checkmark" : "xmark")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(isSuccess ? .ifGreen : .ifRed)
        }
    }

    // MARK: - Detalles de éxito

    private var successDetails: some View {
        VStack(spacing: 0) {
            detailRow(label: "ID de transacción", value: result.transactionID)
            if let arrival = result.estimatedArrival {
                Divider().padding(.leading, 16)
                detailRow(
                    label: "Llegada estimada",
                    value: arrival.formatted(date: .abbreviated, time: .omitted)
                )
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)
            Spacer()
            Text(value)
                .font(.ifBody)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Botones

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                coordinator.dismissTransfer()
            } label: {
                Text("Volver al inicio")
                    .font(.ifHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 14))
            }

            if !isSuccess {
                Button {
                    coordinator.transferNavPath.removeLast(
                        min(2, coordinator.transferNavPath.count)
                    )
                } label: {
                    Text("Intentar de nuevo")
                        .font(.ifBody)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.bottom, 24)
    }
}
