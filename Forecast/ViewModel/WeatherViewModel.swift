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
    private var defaultLocation: CLLocation = .init()
    
    init() { // Loads last saved location if there is one
        if let lastSavedLocation = UserDefaults.standard.data(forKey: "savedLocation"),
           let decodedLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: lastSavedLocation) {
            Task {
                self.defaultLocation = decodedLocation
                try await fetchCurrentWeather(fromLocation: decodedLocation)
            }
        }
    }
    
    func changeLocation(to newLocation: String) async {
        do {
            if let placemark = try await geocode(location: newLocation) {
                try await fetchCurrentWeather(fromLocation: placemark.location)
                
                if let encodedLocation = try? NSKeyedArchiver.archivedData(withRootObject: placemark.location ?? defaultLocation, requiringSecureCoding: false) {
                    UserDefaults.standard.set(encodedLocation, forKey: "savedLocation")
                }
            }
        } catch {
            self.error = .locationNotFound
        }
    }
    
    private func geocode(location: String) async throws -> CLPlacemark? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(location)
            if let placemark = placemarks.first {
                return placemark
            }
        } catch {
            throw OWError.locationNotFound
        }
        return nil
    }
    
    func fetchCurrentWeather(fromLocation location: CLLocation?) async throws {
        guard let location else {
            self.error = OWError.locationNotFound
            return
        }
        
        isFetching = true
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first,
            let coordinate = placemark.location?.coordinate,
            let city = placemark.locality {
            do {
                let currentWeather = try await self.client.getCurrentWeather(for: coordinate)
                self.forecasts = try await self.client.getMultiDayForecast(for: coordinate)
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
