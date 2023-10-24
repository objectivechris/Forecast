//
//  ForecastViewModel.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

public class ForecastViewModel {
    
    var dayOftheWeek: String = ""
    var description: String = ""
    var windSpeed: String = ""
    var highTemp: String = ""
    var lowTemp: String = ""
    var humidity: String = ""
    var pressure: String = ""
    var iconURL: URL = URL(string: "www.example.com")!
    
    init(forecast: Forecast) {
        
        if let description = forecast.weatherDetails.first?.description {
            self.description = description.capitalized
        } else {
            self.description = "No description available"
        }
        
        // Helper
        let date = Date(timeIntervalSince1970: forecast.weekday)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        self.dayOftheWeek = weekday
        
        // Helper
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let i = Int((forecast.windDirection + 11.25)/22.5)
        let direction = directions[i % 16]
        let speed = Int(forecast.windSpeed)
        self.windSpeed = "\(speed) m/h \(direction)"
        
        let roundedHighTemp = Int(forecast.temp.high)
        self.highTemp = "\(roundedHighTemp)º"
        
        let roundedLowTemp = Int(forecast.temp.low)
        self.lowTemp = "\(roundedLowTemp)º"
        
        let roundedPressure = Int(forecast.pressure)
        self.pressure = "\(roundedPressure) hPa"
        
        let roundedHumidity = Int(forecast.humidity)
        self.humidity = "\(roundedHumidity)%"
        
        if let icon = forecast.weatherDetails.first?.icon, let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
            self.iconURL = url
        } else {
            self.iconURL = URL(string: "www.example.com")!
        }
    }
}
