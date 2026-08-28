//
//  ErrorStateView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

public struct ErrorStateView: View {

    public let message: String
    public var systemImage: String
    public var title: String?
    public var retryTitle: String
    public var retryAction: (() -> Void)?

    public init(
        message: String,
        systemImage: String = "exclamationmark.triangle",
        title: String? = nil,
        retryTitle: String = "Reintentar",
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.systemImage = systemImage
        self.title = title
        self.retryTitle = retryTitle
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.ifSecondary)

            VStack(spacing: 6) {
                if let title {
                    Text(title)
                        .font(.ifHeadline)
                        .multilineTextAlignment(.center)
                }
                Text(message)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let retryAction {
                Button(retryTitle, action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.ifBlue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
