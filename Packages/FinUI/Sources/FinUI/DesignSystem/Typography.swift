//
//  Typography.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import SwiftUI

public extension Font {
    static let ifLargeTitle = Font.system(size: 34, weight: .bold,     design: .rounded)
    static let ifTitle      = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let ifHeadline   = Font.system(size: 17, weight: .semibold, design: .default)
    static let ifBody       = Font.system(size: 15, weight: .regular,  design: .default)
    static let ifSubhead    = Font.system(size: 13, weight: .regular,  design: .default)
    static let ifCaption    = Font.system(size: 12, weight: .medium,   design: .default)
    static let ifPrice      = Font.system(size: 17, weight: .semibold, design: .monospaced)
    static let ifPriceLarge = Font.system(size: 28, weight: .bold,     design: .monospaced)
}
