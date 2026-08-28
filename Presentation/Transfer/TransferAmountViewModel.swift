//
//  TransferAmountViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class TransferAmountViewModel {

    // MARK: - Estado

    var amountText: String = ""
    private(set) var submitState: LoadState<TransferRequest> = .idle

    // MARK: - Dependencias

    let country: SupportedCountry
    let method: TransferOption
    let flowType: TransferFlowType
    let userID: String

    init(
        country: SupportedCountry,
        method: TransferOption,
        flowType: TransferFlowType,
        userID: String
    ) {
        self.country = country
        self.method = method
        self.flowType = flowType
        self.userID = userID
    }

    var amount: Decimal? {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
    }

    var feeAmount: Decimal {
        guard let amt = amount else { return .zero }
        return method.feeIsPercentage ? (amt * method.fee).rounded(2) : method.fee
    }

    var netAmount: Decimal {
        guard let amt = amount else { return .zero }
        return max(.zero, amt - feeAmount)
    }

    var validationError: String? {
        guard let amt = amount else {
            return amountText.isEmpty ? nil : "Monto inválido"
        }
        if amt < method.minAmount {
            return "Mínimo \(method.minAmount.formatted(.currency(code: "USD")))"
        }
        if amt > method.maxAmount {
            return "Máximo \(method.maxAmount.formatted(.currency(code: "USD")))"
        }
        return nil
    }

    var canContinue: Bool {
        validationError == nil && amount != nil
    }

    // MARK: - Acciones

    func buildRequest() -> TransferRequest? {
        guard let amt = amount, canContinue else { return nil }
        return TransferRequest(userID: userID, method: method, amount: amt, currency: "USD")
    }
}
