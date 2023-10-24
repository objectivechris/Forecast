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
    
    case currentWeather(String)
    case tenDayForecast(String)
    
    private var path: String {
        var endpoint: String
        
        switch self {
        case .currentWeather(let city):
            endpoint = "weather?q=\(city)&units=imperial&apiKey=\(apiKey)"
        case .tenDayForecast(let city):
            endpoint = "forecast/daily?q=\(city)&cnt=10&units=imperial&apikey=\(apiKey)"
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
