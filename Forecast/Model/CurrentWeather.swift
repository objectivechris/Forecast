//
//  CurrentWeather.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

struct CurrentWeather: Codable {
    let details: [WeatherDetails]
    let main: Main
    
    enum CodingKeys: String, CodingKey {
        case details = "weather"
        case main
    }
}

struct Main: Codable {
    let temp: Double
    let humidity: Double
}

struct WeatherDetails: Codable {
    let main: String
    let description: String
    let icon: String
}
