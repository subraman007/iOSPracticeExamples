import Foundation
import UIKit
import Combine

class WeatherViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    var viewModel = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up bindings
        viewModel.$weather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.updateUI(with: weather)
            }
            .store(in: &cancellables)
        

                citySearchBar.searchTextField.publisher(for: \.text)
                    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                    .sink { [weak self] query in
                        self?.viewModel.searchQuery = query ?? ""
                    }
                    .store(in: &cancellables)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.searchTextField.text, !query.isEmpty {
                   viewModel.geocodeAndFetchWeather(for: query)
        }
        searchBar.searchTextField.resignFirstResponder()
    }
    
       
    
    
    func updateUI(with weather: WeatherResponse?) {
        guard let weather = weather else {
            // Handle no weather data
            return
        }
        
        cityNameLabel.text = "City: \(weather.name)"
        temperatureLabel.text = "Temperature: \(weather.main.temp) °F"
        conditionLabel.text = "Condition: \(weather.weather[0].description)"
        humidityLabel.text = "Humidity: \(weather.main.humidity)%"
        windSpeedLabel.text = "Wind Speed: \(weather.wind.speed) m/s"
        feelsLikeLabel.text = "Feels Like: \(weather.main.feels_like) °F"
        // Update other UI elements as needed
    }
}
