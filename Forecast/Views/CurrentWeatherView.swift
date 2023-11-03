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
        
        if viewModel.isFetching {
            ProgressView()
        } else {
            VStack(spacing: 5) {
                
                Text(viewModel.city)
                    .font(.custom("ArialRoundedMTBold", size: 44.0))
                
                HStack(spacing: 0) {
                    AsyncImage(url: viewModel.iconURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 44, height: 44)
                    
                    Text(viewModel.description)
                        .font(.custom("ArialRoundedMTBold", size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.345, blue: 0.0))
                }
                
                Text(viewModel.temperature)
                    .font(.custom("ArialRoundedMTBold", size: 130.0))
                
                HStack(spacing: 10) {
                    Text(viewModel.highTemp)
                    Text(viewModel.lowTemp)
                }
                .font(.custom("ArialRoundedMTBold", size: 23.0))
                .foregroundColor(.gray)
            }
            .background(Color(.clear))
        }
    }
}

#Preview {
    CurrentWeatherView(viewModel: WeatherViewModel.example())
}
