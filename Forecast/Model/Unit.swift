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
    
    var abbreviatedTitle: String {
        switch self {
        case .metric: "Cº"
        case .imperial: "Fº"
        }
    }
}
