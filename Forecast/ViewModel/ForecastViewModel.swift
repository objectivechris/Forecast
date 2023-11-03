//
//  ForecastViewModel.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

public class ForecastViewModel {
    
    let dayOftheWeek: String
    let description: String
    let cloudiness: String
    let highTemp: String
    let lowTemp: String
    let humidity: String
    let precipitation: String
    let iconURL: URL
    
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
        let weekday = Calendar.current.isDateInToday(date) ? "Today" : formatter.string(from: date)
        self.dayOftheWeek = weekday
        
        let cloudiness = Int(forecast.cloudiness)
        self.cloudiness = "\(cloudiness)%"
        
        let roundedHighTemp = Int(forecast.temp.high)
        self.highTemp = "\(roundedHighTemp)º"
        
        let roundedLowTemp = Int(forecast.temp.low)
        self.lowTemp = "\(roundedLowTemp)º"
        
        self.precipitation = "\(Int(forecast.precipitation * 100))%"
        
        let roundedHumidity = Int(forecast.humidity)
        self.humidity = "\(roundedHumidity)%"
        
        if let icon = forecast.weatherDetails.first?.icon, let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
            self.iconURL = url
        } else {
            self.iconURL = URL(string: "www.example.com")!
        }
    }
}
