//
//  NetworkErrorMappingTests.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Testing
import Foundation
import FinCore
@testable import InvestFlow

@Suite("NetworkErrorMapping")
struct NetworkErrorMappingTests {

    @Test func unauthorized_mapsTo_ifUnauthorized() {
        let result = mapToIFError(NetworkError.unauthorized)
        #expect(result == .unauthorized)
    }

    @Test func sessionExpired_mapsTo_ifUnauthorized() {
        let result = mapToIFError(NetworkError.sessionExpired)
        #expect(result == .unauthorized)
    }

    @Test func requestFailed404_mapsTo_notFound() {
        let result = mapToIFError(NetworkError.requestFailed(statusCode: 404))
        if case .notFound = result { } else {
            Issue.record("Expected .notFound, got \(result)")
        }
    }

    @Test func requestFailed500_mapsTo_serverError() {
        let result = mapToIFError(NetworkError.requestFailed(statusCode: 500))
        if case .serverError(let code) = result {
            #expect(code == 500)
        } else {
            Issue.record("Expected .serverError, got \(result)")
        }
    }

    @Test func serverError503_mapsTo_serverError() {
        let result = mapToIFError(NetworkError.serverError(statusCode: 503, message: nil))
        if case .serverError(let code) = result {
            #expect(code == 503)
        } else {
            Issue.record("Expected .serverError, got \(result)")
        }
    }

    @Test func urlErrorNoInternet_mapsTo_networkUnavailable() {
        let result = mapToIFError(URLError(.notConnectedToInternet))
        #expect(result == .networkUnavailable)
    }

    @Test func urlErrorTimedOut_mapsTo_networkUnavailable() {
        let result = mapToIFError(URLError(.timedOut))
        #expect(result == .networkUnavailable)
    }

    @Test func cancelled_mapsTo_networkUnavailable() {
        let result = mapToIFError(NetworkError.cancelled)
        #expect(result == .networkUnavailable)
    }

    @Test func ifError_passesThroughUnchanged() {
        let input = IFError.validationFailed("test")
        let result = mapToIFError(input)
        #expect(result == input)
    }

    @Test func unknownError_mapsTo_unknown() {
        let result = mapToIFError(MockError.simulatedFailure)
        if case .unknown = result { } else {
            Issue.record("Expected .unknown, got \(result)")
        }
    }
}
