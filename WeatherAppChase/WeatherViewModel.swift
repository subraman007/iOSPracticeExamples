//
//  WeatherViewModel.swift
//  WeatherAppChase
//
//  Created by Subramanian Sankaran on 10/1/23.
//  Copyright © 2023 Chase. All rights reserved.
//
import Combine
import CoreLocation
import MapKit

class WeatherViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var city: String = ""
    @Published var weather: WeatherResponse?
    @Published var selectedLocation: MKLocalSearchCompletion?
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var geocoder = CLGeocoder()
    private lazy var searchCompleter = MKLocalSearchCompleter()
    
    init() {
        // Set up bindings for autocomplete
        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.searchCompleter.queryFragment = query
            }
            .store(in: &cancellables)
        
        // Set up bindings for selected autocomplete item
        $selectedLocation
            .sink { [weak self] location in
                if let location = location {
                    self?.geocodeAndFetchWeather(for: location.title)
                }
            }
            .store(in: &cancellables)
        
        // Load last selected location on app launch
        if let lastSelectedLocation = loadLastSelectedLocation() {
            geocodeAndFetchWeather(for: lastSelectedLocation)
        }
        
        searchCompleter.publisher(for: \.results)
            .sink { [weak self] results in
                self?.selectedLocation = results.first
            }
            .store(in: &cancellables)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        WeatherService.fetchWeather(latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { _ in }) { weatherResponse in
                self.weather = weatherResponse
            }
            .store(in: &cancellables)
    }
    
    func fetchWeatherForCurrentLocation() {
        // Implement location-based weather fetching
        // You can use Core Location for this purpose
    }
    
    func geocodeAndFetchWeather(for location: String) {
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, let placeMarkLocation = placemark.location else {
                print("Error geocoding location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }


            self?.saveLastSelectedLocation(location)
            self?.fetchWeather(latitude: placeMarkLocation.coordinate.latitude, longitude: placeMarkLocation.coordinate.longitude)
        }
    }
    
    
    // MARK: - Last Selected Location Persistence
       
       private let lastSelectedLocationKey = "LastSelectedLocation"
       
       private func saveLastSelectedLocation(_ location: String) {
           UserDefaults.standard.set(location, forKey: lastSelectedLocationKey)
       }
       
       private func loadLastSelectedLocation() -> String? {
           return UserDefaults.standard.string(forKey: lastSelectedLocationKey)
       }
}

