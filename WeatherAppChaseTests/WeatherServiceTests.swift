//
//  WeatherServiceTests.swift
//  WeatherAppChaseTests
//
//  Created by Subramanian Sankaran on 10/2/23.
//  Copyright © 2023 Chase. All rights reserved.
//

import Foundation
import XCTest
import Combine
@testable import WeatherAppChase

class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        weatherService = WeatherService()
    }

    func testFetchWeather() {
        // Create an expectation to wait for the asynchronous network request
        let expectation = XCTestExpectation(description: "Weather fetched")

        // Simulate coordinates for testing
        let latitude = 37.7749
        let longitude = -122.4194

        // Perform the fetchWeather request
        weatherService.fetchWeather(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                }
            }) { weatherResponse in
                XCTAssertNotNil(weatherResponse)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Wait for the expectation to be fulfilled, timeout if necessary
        wait(for: [expectation], timeout: 5.0)
    }

    override func tearDown() {
        super.tearDown()
        weatherService = nil
    }
}
