//
//  WeatherViewController.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Combine
import CoreLocation
import UIKit
import SwiftUI

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @Published var viewModel = WeatherViewModel()
    
    private var expanded = false
    private var selectedRowIndex: Int?
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    private var forecasts = [Forecast]() {
        didSet {
            tableView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ForecastCell", bundle: nil), forCellReuseIdentifier: "ForecastCell")
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            showAlert(title: "Location Disabled", message: "Please review your location permissions in Settings")
        }
        
        viewModel.$forecasts
            .receive(on: RunLoop.main)
            .sink { [weak self] forecasts in
                self?.forecasts = forecasts
            }
            .store(in: &subscriptions)
    }
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: CurrentWeatherView(viewModel: self.viewModel))
    }
    
    private func showAlert(title: String = "Uh Oh", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Task {
            await self.viewModel.changeLocation(to: textField.text ?? "")
            textField.text = nil
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        cell.configure(with: ForecastViewModel(forecast: forecasts[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == selectedRowIndex && expanded) ? 120 : 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRowIndex != indexPath.row {
            expanded = true
            selectedRowIndex = indexPath.row
        } else {
            expanded = false
            selectedRowIndex = nil
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}


extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            Task {
                try await viewModel.fetchCurrentWeather(fromLocation: manager.location)
            }
            manager.stopUpdatingLocation()
        default:
            showAlert(message: "Please check your location permissions.")
            tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        Task {
            try await viewModel.fetchCurrentWeather(fromLocation: location)
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Update Error", message: error.localizedDescription)
    }
}
