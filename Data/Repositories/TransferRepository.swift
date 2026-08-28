//
//  TransferRepository.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

final class TransferRepository: TransferRepositoryProtocol, Sendable {

    init() {}

    // MARK: - TransferRepositoryProtocol

    func fetchSupportedCountries() async throws -> [SupportedCountry] {
        try await Task.sleep(for: .milliseconds(150))
        return Self.mockCountries
    }

    func fetchTransferOptions(
        for countryID: String,
        flowType: TransferFlowType
    ) async throws -> [TransferOption] {
        try await Task.sleep(for: .milliseconds(120))
        return Self.mockOptions(for: countryID, flowType: flowType)
    }

    func initiateTransfer(_ request: TransferRequest) async throws -> TransferResult {
        try await Task.sleep(for: .milliseconds(300))
        let txID = "TXN-\(UUID().uuidString.prefix(8).uppercased())"
        let arrival = Calendar.current.date(byAdding: .day, value: 2, to: Date())
        return TransferResult(
            transactionID: txID,
            status: .completed,
            estimatedArrival: arrival
        )
    }
}

// MARK: - Datos mock

private extension TransferRepository {

    static let mockCountries: [SupportedCountry] = [
        SupportedCountry(id: "AR", name: "Argentina",       flagEmoji: "🇦🇷", dialCode: "+54",  isSupported: true),
        SupportedCountry(id: "BR", name: "Brasil",          flagEmoji: "🇧🇷", dialCode: "+55",  isSupported: true),
        SupportedCountry(id: "CL", name: "Chile",           flagEmoji: "🇨🇱", dialCode: "+56",  isSupported: true),
        SupportedCountry(id: "CO", name: "Colombia",        flagEmoji: "🇨🇴", dialCode: "+57",  isSupported: true),
        SupportedCountry(id: "MX", name: "México",          flagEmoji: "🇲🇽", dialCode: "+52",  isSupported: true),
        SupportedCountry(id: "PE", name: "Perú",            flagEmoji: "🇵🇪", dialCode: "+51",  isSupported: true),
        SupportedCountry(id: "US", name: "Estados Unidos",  flagEmoji: "🇺🇸", dialCode: "+1",   isSupported: true),
        SupportedCountry(id: "UY", name: "Uruguay",         flagEmoji: "🇺🇾", dialCode: "+598", isSupported: true),
        SupportedCountry(id: "VE", name: "Venezuela",       flagEmoji: "🇻🇪", dialCode: "+58",  isSupported: false),
    ]

    static func mockOptions(for countryID: String, flowType: TransferFlowType) -> [TransferOption] {
        switch flowType {
        case .deposit:    return depositOptions(for: countryID)
        case .withdrawal: return withdrawalOptions(for: countryID)
        }
    }

    static func depositOptions(for countryID: String) -> [TransferOption] {
        [
            TransferOption(
                id: "dep_bank_\(countryID)",
                method: .bankTransfer,
                name: "Transferencia bancaria",
                description: "Desde tu cuenta bancaria local",
                minAmount: 10,
                maxAmount: 50_000,
                estimatedTime: "1-3 días hábiles",
                fee: .zero,
                feeIsPercentage: false
            ),
            TransferOption(
                id: "dep_card_\(countryID)",
                method: .debitCard,
                name: "Tarjeta de débito",
                description: "Depósito instantáneo con tu tarjeta",
                minAmount: 5,
                maxAmount: 5_000,
                estimatedTime: "Inmediato",
                fee: 0.015,
                feeIsPercentage: true
            ),
            TransferOption(
                id: "dep_wire_\(countryID)",
                method: .wire,
                name: "Wire transfer",
                description: "Transferencia internacional SWIFT",
                minAmount: 500,
                maxAmount: 500_000,
                estimatedTime: "2-5 días hábiles",
                fee: 25,
                feeIsPercentage: false,
                isAvailable: countryID == "US"
            ),
        ]
    }

    static func withdrawalOptions(for countryID: String) -> [TransferOption] {
        [
            TransferOption(
                id: "wit_bank_\(countryID)",
                method: .bankTransfer,
                name: "A cuenta bancaria",
                description: "Retiro a tu cuenta registrada",
                minAmount: 20,
                maxAmount: 100_000,
                estimatedTime: "2-4 días hábiles",
                fee: .zero,
                feeIsPercentage: false
            ),
            TransferOption(
                id: "wit_wire_\(countryID)",
                method: .wire,
                name: "Wire internacional",
                description: "Transferencia a cuenta en el exterior",
                minAmount: 1_000,
                maxAmount: 500_000,
                estimatedTime: "3-5 días hábiles",
                fee: 30,
                feeIsPercentage: false,
                isAvailable: countryID == "US"
            ),
        ]
    }
}
