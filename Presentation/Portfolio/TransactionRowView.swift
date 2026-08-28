//
//  TransactionRowView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI
import FinCore
import FinUI

struct TransactionRowView: View {

    let transaction: FinCore.Transaction

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ifBody)
                    .fontWeight(.medium)
                Text(formattedDate)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
            }

            Spacer()

            Text(formattedAmount)
                .font(.ifBody)
                .fontWeight(.semibold)
                .foregroundStyle(amountColor)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Auxiliares de presentación

    private var title: String {
        switch transaction.type {
        case .buy:        return "Compra \(transaction.instrumentID ?? "")"
        case .sell:       return "Venta \(transaction.instrumentID ?? "")"
        case .dividend:   return "Dividendo \(transaction.instrumentID ?? "")"
        case .deposit:    return "Depósito"
        case .withdrawal: return "Retiro"
        case .fee:        return "Comisión"
        }
    }

    private var iconName: String {
        switch transaction.type {
        case .buy:        return "arrow.down.left"
        case .sell:       return "arrow.up.right"
        case .dividend:   return "dollarsign.circle"
        case .deposit:    return "plus.circle"
        case .withdrawal: return "minus.circle"
        case .fee:        return "percent"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .buy:        return .ifBlue
        case .sell:       return .ifGreen
        case .dividend:   return .ifGreen
        case .deposit:    return .ifGreen
        case .withdrawal: return .ifRed
        case .fee:        return .ifSecondary
        }
    }

    private var amountColor: Color {
        transaction.netAmount >= .zero ? .ifGreen : .ifRed
    }

    // MARK: - Formateadores

    // currencyCode varía por transacción: se setea antes de cada uso.
    // Es seguro porque View.body (y las propiedades que llama) corre en @MainActor.
    @MainActor private static let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.positivePrefix = "+"
        return f
    }()

    @MainActor private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale(identifier: "es")
        return f
    }()

    private var formattedAmount: String {
        Self.amountFormatter.currencyCode = transaction.currency.rawValue
        return Self.amountFormatter.string(from: transaction.netAmount as NSDecimalNumber) ?? "-"
    }

    private var formattedDate: String {
        Self.dateFormatter.string(from: transaction.executedAt)
    }
}
