//
//  Unit.swift
//  Forecast
//
//  Created by Chris Rene on 10/29/23.
//

import Foundation
import UIKit

enum Unit: String, CaseIterable {
    case metric
    case imperial
    case kelvin
    
    var title: String {
        switch self {
        case .metric: "Celsius (ºC)"
        case .imperial: "Fahrenheit (ºF)"
        case .kelvin: "Kelvin (ºK)"
        }
    }
    
    var abbreviatedTitle: String {
        switch self {
        case .metric: "ºC"
        case .imperial: "ºF"
        case .kelvin: "ºK"
        }
    }
}
