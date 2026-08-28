//
//  MarketplaceViewModelTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("MarketplaceViewModel")
@MainActor
struct MarketplaceViewModelTests {

    // MARK: - Fixtures

    private static let instruments: [Instrument] = [
        .stub(id: "AAPL", name: "Apple Inc.",   type: .stock),
        .stub(id: "TSLA", name: "Tesla Inc.",   type: .stock),
        .stub(id: "SPY",  name: "S&P 500 ETF",  type: .etf),
        .stub(id: "BTC",  name: "Bitcoin",      type: .crypto),
    ]

    private static var quotes: [Quote] {
        instruments.map { Quote.stub(id: $0.id) }
    }

    private func makeViewModel(
        instruments: [Instrument] = MarketplaceViewModelTests.instruments,
        quotes: [Quote]? = nil,
        error: Error? = nil
    ) -> MarketplaceViewModel {
        let repo = MockMarketRepository(
            instruments: instruments,
            quotes: quotes ?? instruments.map { Quote.stub(id: $0.id) },
            error: error
        )
        return MarketplaceViewModel(
            getInstrumentsUseCase: GetInstrumentsUseCase(repository: repo),
            getTopMoversUseCase: GetTopMoversUseCase(),
            getTrendingUseCase: GetTrendingAssetsUseCase(),
            getNewsUseCase: GetMarketNewsUseCase()
        )
    }

    // MARK: - Carga

    @Test func load_success_populatesLoadedData() async {
        let vm = makeViewModel()
        await vm.load()

        #expect(vm.data != nil)
        #expect(vm.data?.allItems.count == 4)
    }

    @Test func load_failure_setsFailedState() async {
        let vm = makeViewModel(error: MockError.simulatedFailure)
        await vm.load()

        #expect(vm.data == nil)
        if case .failed = vm.state {} else {
            Issue.record("Expected .failed state, got \(vm.state)")
        }
    }

    // MARK: - isFiltering

    @Test func isFiltering_falseWhenNoSearchAndCategoryAll() async {
        let vm = makeViewModel()
        await vm.load()

        #expect(vm.isFiltering == false)
    }

    @Test func isFiltering_trueWhenSearchTextPresent() async {
        let vm = makeViewModel()
        await vm.load()
        vm.searchText = "AA"

        #expect(vm.isFiltering == true)
    }

    @Test func isFiltering_trueWhenCategoryNotAll() async {
        let vm = makeViewModel()
        await vm.load()
        vm.selectedCategory = .crypto

        #expect(vm.isFiltering == true)
    }

    // MARK: - Búsqueda

    @Test func filteredItems_matchesBySymbol() async {
        let vm = makeViewModel()
        await vm.load()
        vm.searchText = "tsla"

        #expect(vm.filteredItems.map(\.id) == ["TSLA"])
    }

    @Test func filteredItems_matchesByName_caseInsensitive() async {
        let vm = makeViewModel()
        await vm.load()
        vm.searchText = "bitcoin"

        #expect(vm.filteredItems.map(\.id) == ["BTC"])
    }

    @Test func filteredItems_partialNameMatch_returnsAllMatches() async {
        let vm = makeViewModel()
        await vm.load()
        vm.searchText = "Inc"

        #expect(Set(vm.filteredItems.map(\.id)) == ["AAPL", "TSLA"])
    }

    @Test func filteredItems_noMatch_returnsEmpty() async {
        let vm = makeViewModel()
        await vm.load()
        vm.searchText = "nonexistent-ticker"

        #expect(vm.filteredItems.isEmpty)
    }

    // MARK: - Filtro de categoría

    @Test func filteredItems_byCategory_filtersByInstrumentType() async {
        let vm = makeViewModel()
        await vm.load()
        vm.selectedCategory = .stocks

        #expect(Set(vm.filteredItems.map(\.id)) == ["AAPL", "TSLA"])
    }

    @Test func filteredItems_categoryAll_returnsEverything() async {
        let vm = makeViewModel()
        await vm.load()
        vm.selectedCategory = .all

        #expect(vm.filteredItems.count == 4)
    }

    // MARK: - Combinado

    @Test func filteredItems_searchAndCategory_combineAsAnd() async {
        let vm = makeViewModel()
        await vm.load()
        vm.selectedCategory = .stocks
        vm.searchText = "apple"

        #expect(vm.filteredItems.map(\.id) == ["AAPL"])
    }

    @Test func filteredItems_searchMatchesButCategoryExcludes_returnsEmpty() async {
        let vm = makeViewModel()
        await vm.load()
        vm.selectedCategory = .crypto
        vm.searchText = "apple"

        #expect(vm.filteredItems.isEmpty)
    }

    // MARK: - Guard: no cargado

    @Test func filteredItems_emptyWhenNotLoaded() {
        let vm = makeViewModel()
        vm.searchText = "AAPL"

        #expect(vm.filteredItems.isEmpty)
    }
}
