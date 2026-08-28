//
//  GetSupportedCountriesUseCase.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

/// Devuelve los países habilitados para transferencias, ordenados alfabéticamente.
public struct GetSupportedCountriesUseCase: Sendable {

    private let repository: any TransferRepositoryProtocol

    public init(repository: any TransferRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [SupportedCountry] {
        let all = try await repository.fetchSupportedCountries()
        return all
            .filter { $0.isSupported }
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}
