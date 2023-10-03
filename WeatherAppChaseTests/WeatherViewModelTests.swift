//
//  WeatherViewModelTests.swift
//  WeatherAppChaseTests
//
//  Created by Subramanian Sankaran on 10/2/23.
//  Copyright © 2023 Chase. All rights reserved.
//


import XCTest
import Combine
import CoreLocation
import MapKit
@testable import WeatherAppChase

class MockLocationManager: LocationManager, LocationManagerDelegate {
    var startUpdatingLocationCalled = false

    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
        // Simulate location update
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        delegate?.didUpdateLocation(location)
    }

    func requestWhenInUseAuthorization() {
        // Simulate authorization request
    }

    func didUpdateLocation(_ location: CLLocation) {
        // Simulate delegate method call
    }
}

class MockWeatherService: WeatherServiceProtocol {
    var fetchWeatherCalled = false
    var shouldFail = false
    var latitude: Double?
    var longitude: Double?

    func fetchWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherResponse, Error> {
        fetchWeatherCalled = true
        
        // Assign the values for testing purposes
        self.latitude = latitude
        self.longitude = longitude

        if shouldFail {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            // Simulate fetching weather data
            let weatherData = WeatherResponse(
                coord: Coord(lon: 0.0, lat: 0.0),
                weather: [Weather(id: 800, main: "Clear", description: "Clear sky", icon: "01d")],
                base: "stations",
                main: Main(temp: 273.15, feels_like: 273.15, temp_min: 273.15, temp_max: 273.15, pressure: 1013, humidity: 50),
                visibility: 10000,
                wind: Wind(speed: 2.0, deg: 180),
                clouds: Clouds(all: 0),
                dt: 1632650400,
                sys: Sys(type: 1, id: 1, country: "US", sunrise: 1632650400, sunset: 1632693600),
                timezone: -18000,
                id: 0,
                name: "TestCity",
                cod: 200
            )
            return Just(weatherData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

class WeatherViewModelTests: XCTestCase {
       var viewModel: WeatherViewModel!
       var mockLocationManager: MockLocationManager!
       var mockWeatherService: MockWeatherService!

       override func setUp() {
           super.setUp()
           viewModel = WeatherViewModel()
           mockLocationManager = MockLocationManager()
           mockWeatherService = MockWeatherService()

           // Inject mock dependencies
           viewModel.locationManager = mockLocationManager
           viewModel.weatherService = mockWeatherService
       }

    
    func testGeocodeAndFetchWeather() {
        // Provide a sample location
        let location = "Jersey City"
        viewModel.weatherService = MockWeatherService()
        
        // Trigger the method
        viewModel.geocodeAndFetchWeather(for: location)

        // Assert that location was saved
        XCTAssertEqual(UserDefaults.standard.string(forKey: viewModel.lastSelectedLocationKey), location)
    }

    func testDidUpdateLocation() {
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

        // Trigger the method
        viewModel.didUpdateLocation(location)

        // Assert that weather service was called with correct coordinates
        XCTAssertTrue(mockWeatherService.fetchWeatherCalled)
        XCTAssertEqual(mockWeatherService.latitude, location.coordinate.latitude)
        XCTAssertEqual(mockWeatherService.longitude, location.coordinate.longitude)
    }


    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockLocationManager = nil
        mockWeatherService = nil
    }
}
