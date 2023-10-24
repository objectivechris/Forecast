//
//  OWError.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

enum OWError: LocalizedError {
    case invalidServerResponse
    case requestFailed
    case parsingFailure
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidServerResponse: "The server returned an invalid response."
        case .invalidURL: "URL string is malformed."
        case .requestFailed: "The rquest has failed."
        case .parsingFailure: "There was a parsing error."
        }
    }
}
