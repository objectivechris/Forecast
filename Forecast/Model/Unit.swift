//
//  Unit.swift
//  Forecast
//
//  Created by Chris Rene on 10/29/23.
//

import Foundation
import UIKit

enum Unit: String {
    case metric
    case imperial
    
    var title: String {
        switch self {
        case .metric: "Celsius (Cº)"
        case .imperial: "Fahrenheit (Fº)"
        }
    }
    
    var abbreviatedTitle: String {
        switch self {
        case .metric: "Cº"
        case .imperial: "Fº"
        }
    }
}
