//
//  MarketListViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class MarketListViewModel {
    
    // MARK: - Estado

    var state: LoadState<[(Instrument, Quote)]> = .idle
    var searchText: String = ""
    
    /// Instrumentos filtrados según búsqueda del usuario.
    var filteredItems: [(Instrument, Quote)] {
        guard case .loaded(let items) = state else { return [] }
        
        if searchText.isEmpty { return items }
        
        return items.filter { instrument, _ in
            instrument.id.localizedCaseInsensitiveContains(searchText) ||
            instrument.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Dependencias

    private let getInstrumentsUseCase: GetInstrumentsUseCase

    init(getInstrumentsUseCase: GetInstrumentsUseCase) {
        self.getInstrumentsUseCase = getInstrumentsUseCase
    }

    // MARK: - Acciones

    func loadInstruments() async {
        state = .loading
        
        do {
            let items = try await getInstrumentsUseCase.execute()
            state = .loaded(items)
        } catch {
            IFLogger.error(error, context: "MarketListViewModel.loadInstruments")
            state = .failed(IFError.from(error))
        }
    }
    
    func retry() async {
        await loadInstruments()
    }

    func reload() async {
        state = .idle
        await loadInstruments()
    }
}
