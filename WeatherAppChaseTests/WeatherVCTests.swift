//
//  WeatherVCTests.swift
//  WeatherAppChaseTests
//
//  Created by Subramanian Sankaran on 10/2/23.
//  Copyright © 2023 Chase. All rights reserved.
//

import XCTest
import Combine
@testable import WeatherAppChase  // Replace with your actual app name

class MockWeatherViewModel: WeatherViewModel {
    var fetchWeatherCalled = false

    override func geocodeAndFetchWeather(for city: String) {
        fetchWeatherCalled = true
        // Simulate the weather fetching process
        // You can extend this mock to return predefined weather data for testing
    }
}

class WeatherViewControllerTests: XCTestCase {
    var viewController: WeatherViewController!
    var mockViewModel: MockWeatherViewModel!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController
        viewController.loadViewIfNeeded()

        // Replace the actual viewModel with the mock
        mockViewModel = MockWeatherViewModel()
        viewController.viewModel = mockViewModel
    }

    func testSearchButtonClicked() {
        // Trigger the search button click
        viewController.searchBarSearchButtonClicked(viewController.citySearchBar)

        // Assert that geocodeAndFetchWeather is called in the viewModel
        XCTAssertTrue(mockViewModel.fetchWeatherCalled)
    }
    
    /// 
    func testUpdateUIWithWeatherData() {
        // Create sample weather data for testing
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

        // Call the updateUI method with the sample weather data
        viewController.updateUI(with: weatherData)

        // Assert that UI elements are updated correctly
        XCTAssertEqual(viewController.cityNameLabel.text, "City: TestCity")
        XCTAssertEqual(viewController.temperatureLabel.text, "Temperature: 273.15 °F") // Replace with the expected temperature value
        XCTAssertEqual(viewController.conditionLabel.text, "Condition: Clear sky")
        XCTAssertEqual(viewController.humidityLabel.text, "Humidity: 50%")
        XCTAssertEqual(viewController.windSpeedLabel.text, "Wind Speed: 2.0 m/s")
        XCTAssertEqual(viewController.feelsLikeLabel.text, "Feels Like: 273.15 °F") // Replace with the expected feels like value
    }
    
    // Add more tests as needed for other functionalities

    override func tearDown() {
        super.tearDown()
        viewController = nil
        mockViewModel = nil
    }
}

