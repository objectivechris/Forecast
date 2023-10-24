//
//  OWClient.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

class OWClient {
    
    private let session: URLSession
    
    private init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getCurrentWeather(in city: String) async throws -> CurrentWeather {
        return try await request(url: OWEndpoint.currentWeather(city).url, responseType: CurrentWeather.self)
    }
    
    func getTenDayForecast(in city: String) async throws -> [Forecast] {
        return try await request(url: OWEndpoint.tenDayForecast(city).url, responseType: Forecasts.self).list
    }
}

private extension OWClient {
    // Decodes types that only conform to Decodable
    func request<ResponseType: Decodable>(url: URL?, responseType: ResponseType.Type) async throws -> ResponseType {
        guard let url = url else { throw OWError.invalidURL }
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw OWError.invalidServerResponse }
            let decoder = JSONDecoder()
            return try decoder.decode(ResponseType.self, from: data)
        } catch {
            throw OWError.parsingFailure
        }
    }
}
