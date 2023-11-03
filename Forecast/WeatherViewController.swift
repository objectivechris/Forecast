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
    
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var changeUnitButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var expanded = false
    private var selectedRowIndex: Int?
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private let viewModel = WeatherViewModel()
    private var dataSource: UITableViewDiffableDataSource<Int, Forecast>?
    private var forecasts = [Forecast]() {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Forecast>()
            snapshot.appendSections([1])
            snapshot.appendItems(forecasts)
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ForecastCell", bundle: nil), forCellReuseIdentifier: "ForecastCell")
        dataSource = UITableViewDiffableDataSource<Int, Forecast>(tableView: tableView) { (tableView, indexPath, forecast) -> ForecastCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
            cell.configure(with: ForecastViewModel(forecast: forecast))
            return cell
        }
                
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
                self?.reloadMenu()
                self?.forecasts = []
                self?.forecasts = forecasts
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(message: error.errorDescription ?? "Unknown Error")
            }
            .store(in: &subscriptions)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationController?.navigationBar.isHidden = (UIDevice.current.orientation.isLandscape) ? true : false
    }
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        let currentWeatherVC = UIHostingController(coder: coder, rootView: CurrentWeatherView(viewModel: self.viewModel))
        currentWeatherVC?.view.backgroundColor = .clear
        currentWeatherVC?.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        return currentWeatherVC
    }
    
    @IBAction private func locateMe(_ sender: Any) {
        fetchCurrentWeather(fromLocation: locationManager.location)
        hideKeyboard()
    }
    
    @objc private func hideKeyboard() {
        textField.resignFirstResponder()
    }
    
    private func reloadMenu() {
        var menuActions = [UIAction]()
        for unit in Unit.allCases {
            menuActions.append(setMenuAction(forUnit: unit))
        }
        let menu = UIMenu(title: "Change Unit", children: menuActions)
        changeUnitButton.menu = menu
    }
    
    private func setMenuAction(forUnit unit: Unit) -> UIAction {
        let image: UIImage? = (viewModel.unit == unit) ? .init(systemName: "checkmark") : nil
        let attributes: UIMenuElement.Attributes = (viewModel.unit == unit) ? [.disabled] : []
        return UIAction(title: unit.title, image: image, attributes: attributes) { [unowned self] _ in
            self.viewModel.unit = unit
            self.fetchCurrentWeather(fromLocation: viewModel.placemark?.location ?? locationManager.location)
        }
    }
    
    private func fetchCurrentWeather(fromLocation location: CLLocation?) {
        Task {
            try await viewModel.fetchCurrentWeather(fromLocation: location, unit: viewModel.unit)
            self.unitLabel.text = viewModel.unit.abbreviatedTitle
        }
        self.expanded = false
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
            await viewModel.changeLocation(to: textField.text ?? "")
            textField.text = nil
        }
        
        hideKeyboard()
        return true
    }
}

extension WeatherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == selectedRowIndex && expanded) ? 130 : 55
    }
    
    // Animates cell on  selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRowIndex != indexPath.row {
            expanded = true
            selectedRowIndex = indexPath.row
        } else {
            expanded = false
            selectedRowIndex = nil
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            fetchCurrentWeather(fromLocation: manager.location)
        default:
            showAlert(message: "Please check your location permissions in Settings.")
            tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fetchCurrentWeather(fromLocation: manager.location)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Update Error", message: error.localizedDescription)
    }
}
