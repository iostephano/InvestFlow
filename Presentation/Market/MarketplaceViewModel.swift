//
//  MarketplaceViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class MarketplaceViewModel {

    // MARK: - Resultado agregado de carga

    struct MarketplaceData: Sendable {
        let allItems: [MarketItem]
        let topMovers: TopMovers
        let trending: [MarketItem]
        let news: [MarketNews]
    }

    // MARK: - Estado

    private(set) var state: LoadState<MarketplaceData> = .idle
    var selectedCategory: AssetCategory = .all
    var searchText: String = ""

    var isFiltering: Bool {
        !searchText.isEmpty || selectedCategory != .all
    }

    var filteredItems: [MarketItem] {
        guard case .loaded(let data) = state else { return [] }
        var items = data.allItems
        if let type = selectedCategory.instrumentType {
            items = items.filter { $0.instrument.type == type }
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.instrument.id.localizedCaseInsensitiveContains(searchText) ||
                $0.instrument.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        return items
    }

    var data: MarketplaceData? {
        guard case .loaded(let d) = state else { return nil }
        return d
    }

    // MARK: - Dependencias

    private let getInstrumentsUseCase: GetInstrumentsUseCase
    private let getTopMoversUseCase: GetTopMoversUseCase
    private let getTrendingUseCase: GetTrendingAssetsUseCase
    private let getNewsUseCase: GetMarketNewsUseCase

    init(
        getInstrumentsUseCase: GetInstrumentsUseCase,
        getTopMoversUseCase: GetTopMoversUseCase,
        getTrendingUseCase: GetTrendingAssetsUseCase,
        getNewsUseCase: GetMarketNewsUseCase
    ) {
        self.getInstrumentsUseCase = getInstrumentsUseCase
        self.getTopMoversUseCase   = getTopMoversUseCase
        self.getTrendingUseCase    = getTrendingUseCase
        self.getNewsUseCase        = getNewsUseCase
    }

    // MARK: - Acciones

    func load() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            // Concurrente: instrumentos (throws) + noticias (non-throwing)
            async let pairsTask = getInstrumentsUseCase.execute()
            async let newsTask  = getNewsUseCase.execute()

            let pairs = try await pairsTask
            let news  = await newsTask

            let items    = pairs.map { MarketItem(instrument: $0.0, quote: $0.1) }
            let movers   = getTopMoversUseCase.execute(from: items)
            let trending = getTrendingUseCase.execute(from: items)

            state = .loaded(MarketplaceData(
                allItems: items, topMovers: movers, trending: trending, news: news
            ))
        } catch {
            IFLogger.error(error, context: "MarketplaceViewModel.load")
            state = .failed(IFError.from(error))
        }
    }

    func retry() async {
        state = .idle
        await load()
    }

    func reload() async {
        state = .idle
        await load()
    }
}
