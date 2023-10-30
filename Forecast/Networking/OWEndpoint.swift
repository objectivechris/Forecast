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
    
    case currentWeather(Location, Unit)
    case multiDayForecast(Location, Unit)
    
    private var path: String {
        var endpoint: String
        
        switch self {
        case .currentWeather(let location, let unit):
            endpoint = "weather?lat=\(location.latitude)&lon=\(location.longitude)&units=\(unit.rawValue)&appid=\(apiKey)"
        case .multiDayForecast(let location, let unit):
            endpoint = "forecast/daily?lat=\(location.latitude)&lon=\(location.longitude)&cnt=16&units=\(unit.rawValue)&appid=\(apiKey)"
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
