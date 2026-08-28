//
//  TransferOptionsViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class TransferOptionsViewModel {

    // MARK: - Estado

    private(set) var loadState: LoadState<[TransferOption]> = .idle

    var options: [TransferOption] {
        guard case .loaded(let opts) = loadState else { return [] }
        return opts
    }

    // MARK: - Contexto (solo lectura, se muestra en el encabezado)

    let country: SupportedCountry
    let flowType: TransferFlowType

    // MARK: - Dependencias

    private let getTransferOptionsUseCase: GetTransferOptionsUseCase

    init(
        country: SupportedCountry,
        flowType: TransferFlowType,
        getTransferOptionsUseCase: GetTransferOptionsUseCase
    ) {
        self.country = country
        self.flowType = flowType
        self.getTransferOptionsUseCase = getTransferOptionsUseCase
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading
        do {
            let opts = try await getTransferOptionsUseCase.execute(
                countryID: country.id,
                flowType: flowType
            )
            loadState = .loaded(opts)
        } catch {
            loadState = .failed(IFError.from(error))
        }
    }

    func retry() async {
        loadState = .idle
        await load()
    }
}
