//
//  WeatherViewModel.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import CoreLocation
import Foundation

typealias Location = CLLocationCoordinate2D

@MainActor
public class WeatherViewModel: ObservableObject {
    @Published var city: String = ""
    @Published var description: String = ""
    @Published var temperature: String = ""
    @Published var humidity: String = ""
    @Published var iconURL: URL?
    @Published var forecasts: [Forecast] = []
    @Published var error: OWError?
    @Published var isFetching: Bool = false
    
    private let client = OWClient()
    private let geocoder = CLGeocoder()
    
    init() { // Loads last saved location if there is one
        if let lastSavedLocation = UserDefaults.standard.data(forKey: "savedLocation"),
           let decodedLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: lastSavedLocation) {
            Task {
                try await fetchCurrentWeather(fromLocation: decodedLocation)
            }
        }
    }
    
    func changeLocation(to newLocation: String) async {
        do {
            if let placemark = try await geocoder.geocodeAddressString(newLocation).first {
                try await fetchCurrentWeather(fromLocation: placemark.location)
            }
        } catch {
            self.error = .locationNotFound
        }
    }
    
    private func saveLocation(_ location: CLLocation) {
        if let encodedLocation = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedLocation, forKey: "savedLocation")
        }
    }
    
    func fetchCurrentWeather(fromLocation location: CLLocation?) async throws {
        guard let location else {
            self.error = OWError.locationNotFound
            return
        }
        
        isFetching = true
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first,
            let location = placemark.location,
            let city = placemark.locality {
            do {
                let currentWeather = try await self.client.getCurrentWeather(for: location.coordinate)
                self.forecasts = try await self.client.getMultiDayForecast(for: location.coordinate)
                self.saveLocation(location)
                self.isFetching = false
                
                self.city = city
                if let icon = currentWeather.details.first?.icon {
                    self.iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                }
                
                if let description = currentWeather.details.first?.description {
                    self.description = description.capitalized
                } else {
                    self.description = "No description available"
                }
                
                let roundedTemp = Int(currentWeather.main.temp)
                self.temperature = "\(roundedTemp)º"
                
                let roundedHumidity = Int(currentWeather.main.humidity)
                self.humidity = "Humidity: \(roundedHumidity)%"
            } catch {
                self.error = OWError.locationNotFound
            }
        }
    }
}
