//
//  CurrentWeatherView.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import SwiftUI

struct CurrentWeatherView: View {
    
    @StateObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text(viewModel.cityName)
                .font(.custom("ArialRoundedMTBold", size: 44.0))
           
            HStack(spacing: 0) {
                Image(viewModel.icon)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .shadow(radius: 10)
                
                Text(viewModel.description)
                    .font(.custom("ArialRoundedMTBold", size: 20))
                    .foregroundColor(Color(red: 1.0, green: 0.345, blue: 0.0))
            }
            
            Text(viewModel.temperature)
                .font(.custom("ArialRoundedMTBold", size: 156.0))
            
            Text(viewModel.humidity)
                .font(.custom("ArialRoundedMTBold", size: 23.0))
                .foregroundColor(.gray)
        }
        .background(Color(.clear))
    }
}

#Preview {
    CurrentWeatherView(viewModel: WeatherViewModel())
}
