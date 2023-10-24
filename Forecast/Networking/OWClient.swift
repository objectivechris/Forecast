//
//  OWClient.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import Foundation

class OWClient {
    
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getCurrentWeather(in city: String) async throws -> CurrentWeather {
        return try await request(url: OWEndpoint.currentWeather(city).url, responseType: CurrentWeather.self)
    }
    
    func getTenDayForecast(in city: String) async throws -> [Forecast] {
        return try await request(url: OWEndpoint.tenDayForecast(city).url, responseType: List.self).list
    }
}

private extension OWClient {
    private func request<ResponseType: Decodable>(url: URL?, responseType: ResponseType.Type, completion: @escaping (Result<ResponseType, Error>) -> Void) {

        guard let url = url else {
            completion(.failure(OWError.invalidURL))
            return
        }
        
        let urlRequest = URLRequest(url: url)
                
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(error ?? OWError.invalidServerResponse))
            }
            return
        }
        let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                completion(.failure(OWError.parsingFailure))
            }
        }
        task.resume()
    }
    
    func request<ResponseType: Decodable>(url: URL?, responseType: ResponseType.Type) async throws -> ResponseType {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                request(url: url, responseType: responseType) { result in
                    switch result {
                    case .success(let responseType):
                        continuation.resume(returning: responseType)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            throw OWError.parsingFailure
        }
    }
}
