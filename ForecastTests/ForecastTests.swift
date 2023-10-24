//
//  ForecastTests.swift
//  ForecastTests
//
//  Created by Chris Rene on 10/24/23.
//

import XCTest
@testable import Forecast

final class ForecastTests: XCTestCase {
    
    var forecastMockData: Data!
    var forecasts: [Forecast]!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let filePath = Bundle.main.path(forResource: "ForecastData", ofType: "json") {
            let fileUrl = URL(fileURLWithPath: filePath)
            forecastMockData = try Data(contentsOf: fileUrl)
        }
        
        let decoder = JSONDecoder()
        forecasts = try! decoder.decode(Forecasts.self, from: forecastMockData).list
    }
    
    func testTenDayForecastCount() {
        XCTAssertEqual(forecasts.count, 10)
    }
    
    func testForecastIcon() {
        XCTAssertEqual(forecasts[0].weatherDetails[0].icon, "01d")
    }
    
    func testForecastDescription() {
        XCTAssertEqual(forecasts[0].weatherDetails[0].description, "sky is clear")
    }
}
