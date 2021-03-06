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

struct Forecast: Decodable, Hashable {
    let weekday: TimeInterval
    let temp: Temperature
    let precipitation: Double
    let humidity: Double
    let cloudiness: Double
    let weatherDetails: [WeatherDetails]
    
    enum CodingKeys: String, CodingKey {
        case weekday = "dt"
        case temp
        case precipitation = "pop"
        case humidity
        case cloudiness = "clouds"
        case weatherDetails = "weather"
    }
    
    static func == (lhs: Forecast, rhs: Forecast) -> Bool {
        lhs.weekday == rhs.weekday
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(weekday)
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
