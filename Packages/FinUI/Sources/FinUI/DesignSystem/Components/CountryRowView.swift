//
//  CountryRowView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import SwiftUI
import FinCore

public struct CountryRowView: View {

    public let country: SupportedCountry
    public let onTap: () -> Void

    public init(country: SupportedCountry, onTap: @escaping () -> Void) {
        self.country = country
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(country.flagEmoji)
                    .font(.system(size: 28))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.ifBody)
                        .foregroundStyle(.primary)
                    Text(country.dialCode)
                        .font(.ifSubhead)
                        .foregroundStyle(.ifSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.ifCaption)
                    .foregroundStyle(.ifTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
