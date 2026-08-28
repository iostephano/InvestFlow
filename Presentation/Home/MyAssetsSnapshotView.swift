//
//  MyAssetsSnapshotView.swift
//  InvestFlow
//
//  Created by Stephano Portella on 01/06/2026.
//

import SwiftUI
import FinUI
import FinCore

// MARK: - Tarjeta

/// Tarjeta compacta de vista previa de la watchlist a 2 columnas para HomeView.
///
/// Reglas de layout:
///  - Siempre renderiza exactamente 2 columnas iguales separadas por un divisor vertical.
///  - 0 entradas  → mensaje de estado vacío centrado.
///  - 1 entrada   → la columna izquierda muestra el activo; la derecha muestra un placeholder "+ Seguir más".
///  - 2 entradas  → cada columna muestra un activo.
///  - >2 entradas → los pares rotan cada 3 segundos; si el último par es impar, la columna derecha = placeholder.
///
/// El tap lo maneja el wrapper Button en HomeView.myAssetsSection → coordinator.navigateToWatchlist().
struct MyAssetsSnapshotView: View {

    let entries: [WatchlistEntry]

    @State private var currentGroup = 0

    // MARK: - Lógica de pares

    /// Cantidad total de páginas de 2 ítems.
    private var pairCount: Int {
        max(1, (entries.count + 1) / 2)
    }

    /// Entrada de la columna izquierda para la página actual (siempre presente cuando entries no está vacío).
    private var leftEntry: WatchlistEntry? {
        guard !entries.isEmpty else { return nil }
        let idx = (currentGroup % pairCount) * 2
        return entries.indices.contains(idx) ? entries[idx] : nil
    }

    /// Entrada de la columna derecha para la página actual (nil → se renderiza un placeholder).
    private var rightEntry: WatchlistEntry? {
        guard !entries.isEmpty else { return nil }
        let idx = (currentGroup % pairCount) * 2 + 1
        return entries.indices.contains(idx) ? entries[idx] : nil
    }

    // MARK: - Cuerpo

    var body: some View {
        cardContent
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                        .fill(Material.thinMaterial)
                    RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous)
                        .fill(Color(red: 0.08, green: 0.10, blue: 0.28).opacity(0.60))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: IFRadius.md, style: .continuous))
            // Borde especular — después del clipShape para que el borde nunca se vuelva a recortar
            .premiumSpecularBorder(cornerRadius: IFRadius.md, lineWidth: 1.0)
            .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 4)
            .cardGlow(color: .ifBlue, radius: 22, opacity: 0.16)
            // La rotación solo se dispara cuando hay más de 2 entradas.
            // Mismo patrón de Task-sleep que el autoplay del carrusel de PromoCard.
            .task(id: currentGroup) {
                guard entries.count > 2 else { return }
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation(IFMotion.snap) {
                    currentGroup = (currentGroup + 1) % pairCount
                }
            }
    }

    // MARK: - Despacho de contenido

    @ViewBuilder
    private var cardContent: some View {
        if entries.isEmpty {
            emptyStateContent
        } else {
            twoColumnContent
        }
    }

    // MARK: - Estado vacío

    private var emptyStateContent: some View {
        HStack {
            Spacer()
            VStack(spacing: 5) {
                Image(systemName: "star.circle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(.white.opacity(0.25))
                Text("Aún no sigues activos")
                    .font(.ifCaption)
                    .foregroundStyle(.white.opacity(0.50))
                Text("Agrega estrellas desde Mercado")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.white.opacity(0.28))
            }
            Spacer()
        }
        .padding(.vertical, 22)
    }

    // MARK: - Layout de dos columnas

    private var twoColumnContent: some View {
        HStack(spacing: 0) {
            // Columna izquierda — siempre un activo cuando entries no está vacío
            assetColumn(for: leftEntry)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.white.opacity(0.09))
                .frame(width: 0.5)
                .padding(.vertical, 14)

            // Columna derecha — activo o placeholder
            assetColumn(for: rightEntry)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func assetColumn(for entry: WatchlistEntry?) -> some View {
        if let entry {
            AssetColumnView(entry: entry)
        } else {
            PlaceholderColumnView()
        }
    }
}

// MARK: - Columna de activo

private struct AssetColumnView: View {

    let entry: WatchlistEntry

    private var instrument: Instrument { entry.instrument }
    private var quote: Quote           { entry.quote }

    var body: some View {
        HStack(spacing: 8) {

            // Icono de tipo — 24 × 24, logo de marca cuando está disponible
            InstrumentLogoView(
                instrumentID: instrument.id,
                instrumentType: instrument.type,
                size: 24,
                tintColor: typeColor,
                cornerRadius: 12,
                backgroundOpacity: 0.14,
                logoScale: 0.65
            )

            // Este VStack determina la altura del HStack: ~15 pt + 1 + ~13 pt ≈ 29 pt
            VStack(alignment: .leading, spacing: 1) {
                Text(instrument.id)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(changeFormatted)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(changeColor)
                    .monospacedDigit()
            }

            Spacer(minLength: 4)

            // Sparkline decorativa — al final
            SparklineView(
                points: syntheticPoints(for: instrument.id, positive: quote.isPositive),
                color: changeColor
            )
            .frame(width: 36, height: 14)
        }
        .padding(.horizontal, 12)
        // 22 pt de cada lado → contenido ~29 pt + 44 pt de padding = ~73 pt de altura de tarjeta (objetivo 72–84 pt)
        .padding(.vertical, 22)
    }

    // MARK: - Auxiliares

    private var changeColor: Color {
        quote.isPositive ? .ifGreen : .ifRed
    }

    private var changeFormatted: String {
        let d = Double(truncating: quote.changePercent as NSDecimalNumber)
        return String(format: "%+.2f%%", d)
    }

    private var typeColor: Color { .ifBlue }

    // Sparkline sintética determinista sembrada por instrument.id.
    // Constantes LCG de la familia PCG; la dirección de la tendencia sigue a quote.isPositive.
    // Las entidades de FinCore nunca se modifican — solo es una heurística local de Presentation.
    private func syntheticPoints(for id: String, positive: Bool) -> [CGFloat] {
        var seed = id.unicodeScalars.reduce(UInt64(31337)) { acc, s in
            acc &* 31 &+ UInt64(s.value)
        }
        func next() -> CGFloat {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat(seed >> 33) / CGFloat(1 << 31)
        }
        let count = 10
        return (0..<count).map { i in
            let noise = next()
            let t     = CGFloat(i) / CGFloat(count - 1)
            let trend: CGFloat = positive ? t * 0.40 : -(t * 0.40)
            return noise * 0.55 + 0.22 + trend
        }
    }
}

// MARK: - Columna placeholder

/// Se muestra en la columna derecha cuando un par tiene un solo activo (última entrada impar).
private struct PlaceholderColumnView: View {
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "plus.circle")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(.white.opacity(0.16))
            Text("+ Seguir más")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.28))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 22)
    }
}

// MARK: - Sparkline

private struct SparklineView: View {
    let points: [CGFloat]
    let color: Color

    var body: some View {
        SparklineLine(points: points)
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .opacity(0.85)
    }
}

private struct SparklineLine: Shape {
    let points: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        let minP  = points.min() ?? 0
        let maxP  = points.max() ?? 1
        let range = maxP - minP > 0 ? maxP - minP : 1
        let step  = rect.width / CGFloat(points.count - 1)

        var path = Path()
        for (i, value) in points.enumerated() {
            let x          = CGFloat(i) * step
            let normalized = (value - minP) / range
            let y          = rect.height * (1 - normalized)
            let pt         = CGPoint(x: x, y: y)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        return path
    }
}

// MARK: - Vista previa

#Preview("En seguimiento — Dark") {
    ZStack {
        Color(red: 0.04, green: 0.05, blue: 0.16).ignoresSafeArea()
        VStack(spacing: 24) {

            previewRow("0 activos") {
                MyAssetsSnapshotView(entries: [])
            }
            previewRow("1 activo") {
                MyAssetsSnapshotView(entries: [
                    entry("AAPL", .stock,  pct:  1.23),
                ])
            }
            previewRow("2 activos") {
                MyAssetsSnapshotView(entries: [
                    entry("AAPL", .stock,  pct:  1.23),
                    entry("TSLA", .stock,  pct: -1.80),
                ])
            }
            previewRow("3 activos (rota par 1: AAPL/TSLA → par 2: BTC/placeholder)") {
                MyAssetsSnapshotView(entries: [
                    entry("AAPL", .stock,  pct:  1.23),
                    entry("TSLA", .stock,  pct: -1.80),
                    entry("BTC",  .crypto, pct:  1.89),
                ])
            }
            previewRow("4 activos (rota: AAPL/TSLA → BTC/ETH)") {
                MyAssetsSnapshotView(entries: [
                    entry("AAPL", .stock,  pct:  1.23),
                    entry("TSLA", .stock,  pct: -1.80),
                    entry("BTC",  .crypto, pct:  1.89),
                    entry("ETH",  .crypto, pct: -2.43),
                ])
            }
        }
        .padding(.horizontal, 20)
    }
    .preferredColorScheme(.dark)
}

private func entry(_ id: String, _ type: InstrumentType, pct: Decimal) -> WatchlistEntry {
    WatchlistEntry(
        item: WatchlistItem(instrumentID: id),
        marketItem: MarketItem(
            instrument: Instrument(id: id, name: id, type: type,
                                   currency: .usd, exchange: "DEMO"),
            quote: Quote(id: id, price: 100, change: pct,
                         changePercent: pct, volume: 1_000_000)
        )
    )
}

private func previewRow<C: View>(
    _ label: String, @ViewBuilder content: () -> C
) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(label)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(.white.opacity(0.30))
        content()
    }
}
