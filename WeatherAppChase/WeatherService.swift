//
//  WeatherService.swift
//  WeatherAppChase
//
//  Created by Subramanian Sankaran on 10/1/23.
//  Copyright © 2023 Chase. All rights reserved.
//

import Foundation
import Combine

class WeatherService {
    static let apiKey = "98d866fec5083d71d49d413b8887a8e5"
    static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    static func fetchWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=Imperial")!
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

