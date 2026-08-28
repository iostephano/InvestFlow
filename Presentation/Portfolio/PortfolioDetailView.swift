//
//  PortfolioDetailView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Charts
import FinCore
import SwiftUI
import FinUI

struct PortfolioDetailView: View {

    @State private var viewModel: PortfolioDetailViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: PortfolioDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let perf = viewModel.performance {
                    performanceSection(perf)
                }
                if !viewModel.holdings.isEmpty {
                    holdingsSection
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.ifBackground)
        .navigationTitle(viewModel.portfolio.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { investButton }
        .task { await viewModel.load() }
    }

    // MARK: - Tarjeta de encabezado

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.portfolio.description)
                .font(.ifBody)
                .foregroundStyle(.ifSecondary)

            Divider()

            HStack(spacing: 24) {
                metricPill(
                    icon: viewModel.portfolio.riskLevel.icon,
                    label: "Riesgo",
                    value: viewModel.portfolio.riskLevel.displayName,
                    color: riskColor
                )
                Divider().frame(height: 36)
                metricPill(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Retorno esperado",
                    value: "+\(returnString) / año",
                    color: .ifGreen
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ifCard)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func metricPill(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                Text(value)
                    .font(.ifBody)
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Sección de rendimiento

    private func performanceSection(_ perf: PortfolioPerformance) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rendimiento histórico")
                .font(.ifHeadline)

            periodSelector

            performanceChart(perf)
                .frame(height: 160)

            Divider()

            HStack {
                statCell(label: "Retorno total",    value: pctString(perf.totalReturnPercent),      color: perf.isProfit ? .ifGreen : .ifRed)
                Divider().frame(height: 32)
                statCell(label: "Anualizado",       value: pctString(perf.annualizedReturnPercent), color: perf.isProfit ? .ifGreen : .ifRed)
                Divider().frame(height: 32)
                statCell(label: "Max. caída",       value: "-\(pctString(perf.maxDrawdownPercent))",  color: .ifRed)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ifCard)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    // MARK: - Selector de período

    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(PerformancePeriod.allCases) { period in
                Button {
                    viewModel.selectPeriod(period)
                } label: {
                    Text(period.rawValue)
                        .font(.ifCaption)
                        .fontWeight(viewModel.selectedPeriod == period ? .semibold : .regular)
                        .foregroundStyle(viewModel.selectedPeriod == period ? .white : .primary)
                        .frame(width: 40, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.selectedPeriod == period
                                      ? Color.ifBlue : Color.ifSecondary.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: viewModel.selectedPeriod)
            }
            Spacer()
        }
    }

    // MARK: - Gráfico

    private func performanceChart(_ perf: PortfolioPerformance) -> some View {
        let lineColor = perf.isProfit ? Color.ifGreen : Color.ifRed
        return Chart(perf.dataPoints) { point in
            LineMark(
                x: .value("Fecha",   point.date),
                y: .value("Retorno", Double(truncating: point.returnPercent as NSDecimalNumber))
            )
            .foregroundStyle(lineColor)
            .lineStyle(StrokeStyle(lineWidth: 2))

            AreaMark(
                x: .value("Fecha",   point.date),
                y: .value("Retorno", Double(truncating: point.returnPercent as NSDecimalNumber))
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [lineColor.opacity(0.18), .clear],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
        .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) { _ in AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits)) } }
        .chartYAxis { AxisMarks(position: .trailing) { v in AxisValueLabel { Text("\(v.as(Double.self).map { String(format: "%.0f%%", $0) } ?? "")") } } }
        .chartYScale(domain: .automatic(includesZero: true))
    }

    private func statCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.ifCaption)
                .foregroundStyle(.ifSecondary)
            Text(value)
                .font(.ifBody)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sección de holdings

    private var holdingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Composición")
                .font(.ifHeadline)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            ForEach(viewModel.holdings) { holding in
                HoldingRowView(holding: holding)
                if holding.id != viewModel.holdings.last?.id {
                    Divider().padding(.leading, 66)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ifCard)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    // MARK: - Botón de invertir

    private var investButton: some View {
        Button {
            coordinator.navigateToMarket()
        } label: {
            Text("Invertir en este portafolio")
                .font(.ifHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.ifBlue)
                .cornerRadius(14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Auxiliares

    private var riskColor: Color {
        switch viewModel.portfolio.riskLevel {
        case .conservative: return .ifGreen
        case .moderate:     return Color.orange
        case .aggressive:   return .ifRed
        }
    }

    private var returnString: String {
        String(format: "%.1f%%",
               Double(truncating: viewModel.portfolio.expectedReturnPercent as NSDecimalNumber))
    }

    private func pctString(_ d: Decimal) -> String {
        let v = Double(truncating: d as NSDecimalNumber)
        return String(format: v >= 0 ? "+%.2f%%" : "%.2f%%", v)
    }
}

// MARK: - Fila de holding

private struct HoldingRowView: View {

    let holding: PortfolioHolding

    var body: some View {
        HStack(spacing: 12) {
            typeIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(holding.instrumentID)
                    .font(.ifHeadline)
                Text(holding.instrumentName)
                    .font(.ifCaption)
                    .foregroundStyle(.ifSecondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(allocationString)
                    .font(.ifHeadline)
                    .monospacedDigit()
                allocationBar
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var typeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(typeColor.opacity(0.12))
                .frame(width: 42, height: 42)
            Image(systemName: typeIconName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(typeColor)
        }
    }

    private var allocationBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.ifSecondary.opacity(0.15))
                Capsule()
                    .fill(typeColor)
                    .frame(width: geo.size.width * barFill)
            }
        }
        .frame(width: 80, height: 6)
    }

    private var barFill: CGFloat {
        CGFloat(Double(truncating: holding.allocationPercent as NSDecimalNumber)) / 100.0
    }

    private var allocationString: String {
        String(format: "%.0f%%",
               Double(truncating: holding.allocationPercent as NSDecimalNumber))
    }

    private var typeColor: Color {
        switch holding.instrumentType {
        case .stock:     return .ifBlue
        case .etf:       return Color.purple
        case .crypto:    return Color.orange
        case .portfolio: return .ifGreen
        }
    }

    private var typeIconName: String {
        switch holding.instrumentType {
        case .stock:     return "building.columns"
        case .etf:       return "chart.pie"
        case .crypto:    return "bitcoinsign.circle"
        case .portfolio: return "briefcase"
        }
    }
}
