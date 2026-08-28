//
//  TransferEndpoints.swift
//  InvestFlow
//
//  Created by Stephano Portella on 20/04/2026.
//

import Foundation

// MARK: - GET /transfers/countries

struct GetSupportedCountriesEndpoint: Endpoint {
    var path:   String     { "/transfers/countries" }
    var method: HTTPMethod { .get }
}

// MARK: - GET /transfers/options?country={code}

struct GetTransferOptionsEndpoint: Endpoint {
    let countryCode: String
    var path:   String     { "/transfers/options" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "country", value: countryCode)]
    }
}
