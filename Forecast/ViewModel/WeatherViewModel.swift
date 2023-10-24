//
//  WeatherViewModel.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import CoreLocation
import Foundation

@MainActor
public class WeatherViewModel: ObservableObject {
    @Published var cityName: String = ""
    @Published var description: String = ""
    @Published var temperature: String = ""
    @Published var humidity: String = ""
    @Published var icon: String = ""
    @Published var forecasts: [Forecast] = []
    @Published var error: OWError?
    
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
            if let placemark = try await geocode(location: newLocation), let city = placemark.name, let state = placemark.administrativeArea {
                try await fetchCurrentWeather(fromLocation: placemark.location)
                cityName = "\(city), \(state)"
                
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
        guard let location = location else { return }
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first, let city = placemark.locality, let state = placemark.administrativeArea {
            do {
                let currentWeather = try await self.client.getCurrentWeather(in: city)
                self.forecasts = try await self.client.getTenDayForecast(in: city)
                
                self.cityName = "\(city), \(state)"
                if let icon = currentWeather.details.first?.icon {
                    self.icon = icon
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
    
    private func fetchTenDayForecast(fromLocation location: CLLocation?) async throws -> [Forecast] {
        guard let location = location else { return [] }
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first, let city = placemark.locality {
            do {
                self.forecasts = try await self.client.getTenDayForecast(in: city)
            } catch {
                self.error = OWError.locationNotFound
            }
        }
        return []
    }
}
