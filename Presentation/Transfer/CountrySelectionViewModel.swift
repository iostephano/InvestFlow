//
//  CountrySelectionViewModel.swift
//  InvestFlow
//
//  Created by Stephano Portella on 23/04/2026.
//

import Foundation
import FinCore
import Observation

@MainActor
@Observable
final class CountrySelectionViewModel {

    // MARK: - Estado

    private(set) var loadState: LoadState<[SupportedCountry]> = .idle

    /// País aprobado tras validación KYC satisfactoria. La View lo observa para navegar.
    private(set) var approvedCountry: SupportedCountry? = nil

    /// Estado KYC requerido cuando el usuario no está aprobado. Activa el BottomSheet.
    private(set) var kycRequiredStatus: KYCStatus = .pending

    /// `true` cuando el BottomSheet de KYC debe mostrarse.
    var isKYCSheetPresented: Bool = false

    /// Razón de rechazo visible en la UI.
    private(set) var rejectionReason: String? = nil

    var searchText: String = ""

    // MARK: - Calculadas

    var filteredCountries: [SupportedCountry] {
        guard case .loaded(let all) = loadState else { return [] }
        if searchText.isEmpty { return all }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var isValidating: Bool {
        if case .loading = loadState { return false }
        return approvedCountry == nil && !isKYCSheetPresented && rejectionReason == nil
            ? false : false   // Solo se usa para el indicador de carga por fila si hiciera falta
    }

    let flowType: TransferFlowType

    // MARK: - Dependencias

    private let userID: String
    private let getSupportedCountriesUseCase: GetSupportedCountriesUseCase
    private let validateKYCUseCase: ValidateKYCStatusUseCase

    init(
        flowType: TransferFlowType,
        userID: String,
        getSupportedCountriesUseCase: GetSupportedCountriesUseCase,
        validateKYCUseCase: ValidateKYCStatusUseCase
    ) {
        self.flowType = flowType
        self.userID = userID
        self.getSupportedCountriesUseCase = getSupportedCountriesUseCase
        self.validateKYCUseCase = validateKYCUseCase
    }

    // MARK: - Acciones

    func load() async {
        loadState = .loading
        do {
            let countries = try await getSupportedCountriesUseCase.execute()
            loadState = .loaded(countries)
        } catch {
            loadState = .failed(IFError.from(error))
        }
    }

    func select(_ country: SupportedCountry) async {
        rejectionReason = nil
        approvedCountry = nil

        do {
            let result = try await validateKYCUseCase.execute(userID: userID)
            switch result {
            case .approved:
                approvedCountry = country
            case .requiresVerification(let status):
                kycRequiredStatus = status
                isKYCSheetPresented = true
            case .rejected(let reason):
                rejectionReason = reason
            }
        } catch {
            rejectionReason = IFError.from(error).userMessage
        }
    }

    func clearApprovedCountry() {
        approvedCountry = nil
    }

    func clearRejection() {
        rejectionReason = nil
    }

    func retry() async {
        loadState = .idle
        await load()
    }
}
