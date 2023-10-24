//
//  UIImageView+Extension.swift
//  Forecast
//
//  Created by Chris Rene on 10/23/23.
//

import UIKit

extension UIImageView {
    // Download and cache weather icons for later use
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) async throws {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = placeholder
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw OWError.requestFailed }
            let image = UIImage(data: data)
            let cachedData = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedData, for: request)
            self.image = image
        }
    }
}

