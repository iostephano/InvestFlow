//
//  LoadingView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI

public struct LoadingView: View {
    public var message: String

    public init(message: String = "Cargando...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.4)
            Text(message)
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "Cargando mercado...")
}
