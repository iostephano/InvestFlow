//
//  EmptyStateView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import SwiftUI

public struct EmptyStateView: View {

    public let icon: String
    public let title: String
    public let subtitle: String
    public var ctaTitle: String?
    public var action: (() -> Void)?

    public init(
        icon: String,
        title: String,
        subtitle: String,
        ctaTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.ctaTitle = ctaTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.ifSecondary)

            VStack(spacing: 6) {
                Text(title)
                    .font(.ifHeadline)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.ifSubhead)
                    .foregroundStyle(.ifSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            if let ctaTitle, let action {
                Button(action: action) {
                    Text(ctaTitle)
                        .font(.ifBody)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue, in: Capsule())
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}
