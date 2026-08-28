//
//  TransferOptionRowView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinCore

public struct TransferOptionRowView: View {

    public let option: TransferOption
    public let onTap: () -> Void

    public init(option: TransferOption, onTap: @escaping () -> Void) {
        self.option = option
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                methodIcon
                optionInfo
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.ifCaption)
                    .foregroundStyle(.ifTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subvistas

    private var methodIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(tint.opacity(0.12))
                .frame(width: 44, height: 44)
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundStyle(tint)
        }
    }

    private var optionInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(option.name)
                .font(.ifHeadline)
                .foregroundStyle(.primary)
            Text(option.description)
                .font(.ifSubhead)
                .foregroundStyle(.ifSecondary)
            HStack(spacing: 10) {
                Label(option.estimatedTime, systemImage: "clock")
                    .font(.ifCaption)
                    .foregroundStyle(.ifTertiary)
                Text(feeLabel)
                    .font(.ifCaption)
                    .foregroundStyle(option.fee == .zero ? .ifGreen : .ifTertiary)
            }
        }
    }

    // MARK: - Auxiliares

    private var iconName: String {
        switch option.method {
        case .bankTransfer: return "building.columns.fill"
        case .debitCard:    return "creditcard.fill"
        case .crypto:       return "bitcoinsign.circle.fill"
        case .wire:         return "arrow.left.arrow.right.circle.fill"
        }
    }

    private var tint: Color {
        switch option.method {
        case .bankTransfer: return .ifBlue
        case .debitCard:    return .ifGreen
        case .crypto:       return Color.orange
        case .wire:         return .ifRed
        }
    }

    private var feeLabel: String {
        if option.fee == .zero {
            return "$0.00 comisión"
        } else if option.feeIsPercentage {
            let pct = option.fee * 100
            return "\(pct.formatted(.number.precision(.fractionLength(1))))% comisión"
        } else {
            return "\(option.fee.formatted(.currency(code: "USD"))) comisión"
        }
    }
}
