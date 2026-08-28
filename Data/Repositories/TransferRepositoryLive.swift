//
//  TransferRepositoryLive.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

/// Implementación real de `TransferRepositoryProtocol`.
///
/// No se alcanza desde el build de la demo: `AppCompositionRoot` solo elige este tipo cuando
/// `AppEnvironment.current != .development` (staging/production); el entorno `.development`
/// que usa la demo conecta `TransferRepository` (en memoria) en su lugar.
///
/// Los tres endpoints de abajo están deliberadamente sin implementar — todavía no hay un
/// contrato de backend real (forma de request/response, códigos de error) contra el cual
/// implementar. Cada uno lanza un `IFError` descriptivo en vez de fallar en silencio o
/// crashear, así que una integración futura solo necesita completar el request real una vez
/// que exista el contrato del backend.
final class TransferRepositoryLive: TransferRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    nonisolated func fetchSupportedCountries() async throws -> [SupportedCountry] {
        // Pendiente del contrato real de backend para GET /transfer/countries.
        throw IFError.unknown("TransferRepositoryLive.fetchSupportedCountries not implemented")
    }

    nonisolated func fetchTransferOptions(for countryID: String, flowType: TransferFlowType) async throws -> [TransferOption] {
        // Pendiente del contrato real de backend para GET /transfer/options?country={countryID}&type={flowType}.
        throw IFError.unknown("TransferRepositoryLive.fetchTransferOptions not implemented")
    }

    nonisolated func initiateTransfer(_ request: TransferRequest) async throws -> TransferResult {
        // Pendiente del contrato real de backend para POST /transfer/initiate.
        throw IFError.unknown("TransferRepositoryLive.initiateTransfer not implemented")
    }
}
