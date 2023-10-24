//
//  ForecastCell.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import UIKit

class ForecastCell: UITableViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var tempImageView: UIImageView!
    
    let gray = UIColor(displayP3Red: 243/255, green: 244/255, blue: 246/255, alpha: 1.0)
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = selected ? gray : .white
    }
    
    func configure(with model: ForecastViewModel) {
        weekdayLabel.text = model.dayOftheWeek
        descriptionLabel.text = model.description
        highTempLabel.text = model.highTemp
        lowTempLabel.text = model.lowTemp
        humidityLabel.text = "Humidity: " + model.humidity
        pressureLabel.text = "Pressure: " + model.pressure
        windSpeedLabel.text = "Wind: " + model.windSpeed
        
        Task {
           try await tempImageView.load(url: model.iconURL, placeholder: nil)
        }
    }
}
