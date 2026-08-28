//
//  Colors.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI

public extension ShapeStyle where Self == Color {

    // MARK: Marca
    static var ifGreen:  Color { Color(red: 0.13, green: 0.77, blue: 0.37) }
    static var ifRed:    Color { Color(red: 0.94, green: 0.22, blue: 0.28) }
    static var ifBlue:   Color { Color(red: 0.10, green: 0.47, blue: 0.95) }
    static var ifViolet: Color { Color(red: 0.52, green: 0.18, blue: 0.96) }
    static var ifNavy:   Color { Color(red: 2/255, green: 9/255, blue: 28/255) }  // RGB(2, 9, 28)

    // MARK: Semánticos – colores adaptativos UIColor (requieren @MainActor en Swift 6)
    @MainActor static var ifBackground: Color { Color(UIColor.systemGroupedBackground) }
    @MainActor static var ifCard: Color       { Color(UIColor.secondarySystemGroupedBackground) }
    @MainActor static var ifSecondary: Color  { Color(UIColor.secondaryLabel) }
    @MainActor static var ifTertiary: Color   { Color(UIColor.tertiaryLabel) }

    // MARK: Auxiliar de P&L
    static func plColor(isProfit: Bool) -> Color {
        isProfit ? .ifGreen : .ifRed
    }
}
