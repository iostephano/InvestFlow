//
//  LoadState.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

/// Estado de carga genérico para pantallas de InvestFlow.
public enum LoadState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(IFError)
}

extension LoadState {
    public var ifError: IFError? {
        guard case .failed(let error) = self else { return nil }
        return error
    }

    public var userMessage: String {
        guard case .failed(let error) = self else { return "" }
        return error.userMessage
    }
}
