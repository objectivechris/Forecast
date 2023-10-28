//
//  Forecast.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

struct Forecasts: Decodable {
    var list: [Forecast]
}

struct Forecast: Decodable {
    let weekday: TimeInterval
    let temp: Temperature
    let pressure: Double
    let humidity: Double
    let windSpeed: Double
    let weatherDetails: [WeatherDetails]
    
    enum CodingKeys: String, CodingKey {
        case weekday = "dt"
        case temp
        case pressure
        case humidity
        case windSpeed = "speed"
        case weatherDetails = "weather"
    }
}

struct Temperature: Decodable {
    let low: Double
    let high: Double
    
    enum CodingKeys: String, CodingKey {
        case low = "min"
        case high = "max"
    }
}
