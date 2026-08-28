//
//  TransferRepositoryProtocol.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation

public protocol TransferRepositoryProtocol: Sendable {
    func fetchSupportedCountries() async throws -> [SupportedCountry]

    func fetchTransferOptions(
        for countryID: String,
        flowType: TransferFlowType
    ) async throws -> [TransferOption]

    func initiateTransfer(_ request: TransferRequest) async throws -> TransferResult
}
