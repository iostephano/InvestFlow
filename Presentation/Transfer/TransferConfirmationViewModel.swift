//
//  TransferConfirmationViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class TransferConfirmationViewModel {

    private(set) var submitState: LoadState<TransferResult> = .idle

    let request: TransferRequest
    private let initiateTransfer: InitiateTransferUseCase

    init(request: TransferRequest, initiateTransfer: InitiateTransferUseCase) {
        self.request = request
        self.initiateTransfer = initiateTransfer
    }

    var feeAmount: Decimal {
        let m = request.method
        return m.feeIsPercentage ? (request.amount * m.fee).rounded(2) : m.fee
    }

    var netAmount: Decimal { max(.zero, request.amount - feeAmount) }

    var isLoading: Bool {
        if case .loading = submitState { return true }
        return false
    }

    func clearError() { submitState = .idle }

    func confirm() async -> TransferResult? {
        submitState = .loading
        do {
            let result = try await initiateTransfer.execute(request)
            submitState = .loaded(result)
            return result
        } catch {
            submitState = .failed(IFError.from(error))
            return nil
        }
    }
}
