//
//  OWEndpoint.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

fileprivate let apiKey = "3aa158b2f14a9f493a8c725f8133d704"

enum OWEndpoint {
    private var baseURL: String { "https://api.openweathermap.org/data/2.5/" }
    
    case currentWeather(Double, Double)
    case multiDayForecast(Double, Double)
    
    private var path: String {
        var endpoint: String
        
        switch self {
        case .currentWeather(let lat, let lon):
            endpoint = "weather?lat=\(lat)&lon=\(lon)&units=imperial&appid=\(apiKey)"
        case .multiDayForecast(let lat, let lon):
            endpoint = "forecast/daily?lat=\(lat)&lon=\(lon)&cnt=16&units=imperial&appid=\(apiKey)"
        }
        
        return baseURL + endpoint
    }
    
    var url: URL {
        guard let url = URL(string: path) else {
            preconditionFailure("The url is invalid")
        }
        return url
    }
}
