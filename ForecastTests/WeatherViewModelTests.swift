//
//  WeatherViewModelTests.swift
//  Forecast
//
//  Created by Chris Rene on 10/24/23.
//

import XCTest
@testable import Forecast

final class WeatherViewModelTests: XCTestCase {

    var currentWeatherMockData: Data!
    var currentWeather: CurrentWeather!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let filePath = Bundle.main.path(forResource: "CurrentWeatherData", ofType: "json") {
            let fileUrl = URL(fileURLWithPath: filePath)
            currentWeatherMockData = try Data(contentsOf: fileUrl)
        }
        
        let decoder = JSONDecoder()
        currentWeather = try! decoder.decode(CurrentWeather.self, from: currentWeatherMockData)
    }

    func testCurrentWeatherDescription() throws {
        XCTAssertEqual(currentWeather.details[0].description, "clear sky")
    }
    
    func testCurrentWeatherIcon() throws {
        XCTAssertEqual(currentWeather.details[0].icon, "01d")
    }
}
