//
//  FloatingTabBar.swift
//  InvestFlow
//
//  Created by Stephano Portella on 09/05/2026.
//

import SwiftUI
import FinUI

// MARK: - FloatingTabBar

struct FloatingTabBar: View {

    @Binding var selection: IFTab
    @Namespace private var posNS
    @Namespace private var glassNS

    // MARK: - Constantes de diseño

    private static let barHeight:  CGFloat = 76
    private static let hPad:       CGFloat = 6
    private static let iInset:     CGFloat = 3
    private static let indicatorH: CGFloat = barHeight - iInset * 2 - 4

    // MARK: - Cuerpo

    var body: some View {
        ZStack {
            GlassEffectContainer(spacing: 0) {
                ZStack {
                    anchorLayer
                    indicatorLayer
                }
            }
            buttonsLayer
        }
        .frame(height: Self.barHeight)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: 6)
        .shadow(color: .black.opacity(0.03), radius: 4,  x: 0, y: 1)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Capa de anclaje

    private var anchorLayer: some View {
        HStack(spacing: 0) {
            ForEach(IFTab.allCases, id: \.self) { tab in
                // El HStack interior centra el ancla dentro del slot.
                // .padding(.horizontal, iInset) lo separa de los bordes del slot.
                HStack {
                    Color.clear
                        .frame(height: Self.indicatorH)
                        .matchedGeometryEffect(id: tab, in: posNS, isSource: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Self.iInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Self.hPad)
    }

    // MARK: - Capa del indicador

    private var indicatorLayer: some View {
        Color.clear
            .glassEffect(.regular, in: Capsule())
            .glassEffectID("tabIndicator", in: glassNS)
            .matchedGeometryEffect(id: selection, in: posNS, isSource: false)
            .allowsHitTesting(false)
    }

    // MARK: - Capa de botones

    private var buttonsLayer: some View {
        HStack(spacing: 0) {
            ForEach(IFTab.allCases, id: \.self) { tab in
                FloatingTabItem(
                    tab: tab,
                    isSelected: selection == tab,
                    onTap: {
                        guard selection != tab else { return }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.40, dampingFraction: 0.62)) {
                            selection = tab
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Self.hPad)
    }
}

// MARK: - FloatingTabItem

private struct FloatingTabItem: View {

    let tab: IFTab
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 26, height: 26)
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? Color.ifBlue : Color.white.opacity(0.42))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(IFTabPressStyle())
    }

    private var iconName: String {
        switch tab {
        case .home:      return isSelected ? "house.fill"     : "house"
        case .market:    return "chart.line.uptrend.xyaxis"
        case .watchlist: return isSelected ? "star.fill"      : "star"
        case .portfolio: return isSelected ? "briefcase.fill" : "briefcase"
        }
    }
}

// MARK: - IFTabPressStyle

private struct IFTabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.70 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Vista previa

#Preview("Floating Tab Bar — Dark") {
    PreviewWrapper(initial: .home)
        .preferredColorScheme(.dark)
}

#Preview("Floating Tab Bar — Light") {
    PreviewWrapper(initial: .market)
}

private struct PreviewWrapper: View {
    @State var selection: IFTab
    init(initial: IFTab) { _selection = State(initialValue: initial) }

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowBackground().ignoresSafeArea()

            VStack(spacing: 12) {
                ForEach(0..<8, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)

            FloatingTabBar(selection: $selection)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
