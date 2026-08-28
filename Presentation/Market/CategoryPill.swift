//
//  CategoryPill.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import FinCore
import SwiftUI
import FinUI

struct CategoryPill: View {

    let category: AssetCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(.ifCaption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
                .background(Color.ifBlue.opacity(isSelected ? 1 : 0), in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
