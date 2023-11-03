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
class WeatherViewModel: ObservableObject {
    @Published var city: String = ""
    @Published var description: String = ""
    @Published var temperature: String = ""
    @Published var highTemp: String = ""
    @Published var lowTemp: String = ""
    @Published var iconURL: URL?
    @Published var forecasts: [Forecast] = []
    @Published var unit: Unit = .imperial
    @Published var error: OWError?
    @Published var isFetching: Bool = false
    @Published var placemark: CLPlacemark?
    
    private let client = OWClient()
    private let geocoder = CLGeocoder()
    
    init() { // Loads last saved location & unit if there is one
        if let data = UserDefaults.standard.data(forKey: "savedInfo"),
            let dict = try? NSKeyedUnarchiver.unarchivedDictionary(keysOfClasses: [NSString.self], objectsOfClasses: [CLLocation.self, NSString.self], from: data) as? [String: Any],
           let location = dict["savedLocation"] as? CLLocation,
            let unit = dict["savedUnit"] as? String {
            Task {
                try await fetchCurrentWeather(fromLocation: location, unit: Unit(rawValue: unit) ?? .imperial)
            }
        }
    }
    
    private func saveLocation(_ location: CLLocation) {
        let dict: [String: Any] = ["savedLocation": location, "savedUnit": NSString(string: unit.rawValue)]
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "savedInfo")
        }
    }
    
    func changeLocation(to newLocation: String) async {
        do {
            if let placemark = try await geocoder.geocodeAddressString(newLocation).first {
                try await fetchCurrentWeather(fromLocation: placemark.location, unit: unit)
            }
        } catch {
            self.error = .locationNotFound
        }
    }
    
    func fetchCurrentWeather(fromLocation location: CLLocation?, unit: Unit) async throws {
        guard let location else {
            error = OWError.locationNotFound
            return
        }
        
        self.isFetching = true
        self.unit = unit
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first, let location = placemark.location {
            do {
                let currentWeather = try await self.client.getCurrentWeather(for: location.coordinate, unit: unit)
                self.forecasts = try await self.client.getMultiDayForecast(for: location.coordinate, unit: unit)
                self.saveLocation(location)
                self.placemark = placemark
                self.isFetching = false
                
                self.city = placemark.locality ?? placemark.country ?? "Unknown City"
                if let icon = currentWeather.details.first?.icon {
                    self.iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                }
                
                if let description = currentWeather.details.first?.description {
                    self.description = description.capitalized
                } else {
                    self.description = "No description available"
                }
                
                self.temperature = "\(Int(currentWeather.main.temp.rounded()))º"
                self.highTemp = "H:\(Int(currentWeather.main.high.rounded()))º"
                self.lowTemp = "L:\(Int(currentWeather.main.low.rounded()))º"
                
            } catch {
                self.error = OWError.locationNotFound
            }
        }
    }
}

extension WeatherViewModel {
    static func example() -> WeatherViewModel {
        let vm = WeatherViewModel()
        vm.city = "Atlanta"
        vm.description = "Cloudy"
        vm.temperature = "42º"
        vm.lowTemp = "L:34º"
        vm.highTemp = "H:67º"
        vm.iconURL = URL(string: "https://openweathermap.org/img/wn/01d@2x.png")
        return vm
    }
}
