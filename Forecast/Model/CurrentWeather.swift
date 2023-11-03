//
//  CurrentWeather.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

struct CurrentWeather: Decodable {
    let details: [WeatherDetails]
    let main: Main
    
    enum CodingKeys: String, CodingKey {
        case details = "weather"
        case main
    }
}

struct Main: Decodable {
    let temp: Double
    let humidity: Double
    let low: Double
    let high: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case low = "temp_min"
        case high = "temp_max"
    }
}

struct WeatherDetails: Decodable {
    let main: String
    let description: String
    let icon: String
}
