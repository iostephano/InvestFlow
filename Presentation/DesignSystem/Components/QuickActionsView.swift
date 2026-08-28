//
//  QuickActionsView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinUI

struct QuickActionsView: View {

    let actions: [HomeViewModel.QuickActionType]
    let onTap: (HomeViewModel.QuickActionType) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                actionButton(for: action)
                if index < actions.count - 1 {
                    // El separador abarca solo la zona del icono (60 pt — un poco más alto que
                    // el círculo de 56 pt para que no parezca recortado contra el borde del icono).
                    Rectangle()
                        .fill(.white.opacity(0.09))
                        .frame(width: 0.5, height: 60)
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(for action: HomeViewModel.QuickActionType) -> some View {
        Button {
            onTap(action)
        } label: {
            VStack(spacing: 10) {
                Image(assetName(for: action))
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 56, height: 56)

                Text(action.title)
                    .font(.ifCaption)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.ifPress)
    }

    private func assetName(for action: HomeViewModel.QuickActionType) -> String {
        switch action {
        case .deposit:  return "action_deposit"
        case .withdraw: return "action_withdraw"
        case .invest:   return "action_invest"
        }
    }
}

// MARK: - Vista previa

#Preview("Quick Actions — Dark") {
    ZStack {
        GlowBackground().ignoresSafeArea()
        QuickActionsView(
            actions: HomeViewModel.QuickActionType.allCases,
            onTap: { _ in }
        )
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                    .fill(Material.thinMaterial)
                RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.16, blue: 0.36).opacity(0.55))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.28), location: 0.0),
                            .init(color: .white.opacity(0.10), location: 0.4),
                            .init(color: .white.opacity(0.03), location: 1.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .padding(.horizontal, 20)
    }
    .preferredColorScheme(.dark)
}
