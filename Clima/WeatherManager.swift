
import UIKit

protocol WeatherProtocol {
    func updateUI(_ weather: WeatherObject)
    func errorFailed(_ error: Error)
}
//you create the protocol in the class that will use the protocol

let apiKey = ""
//api key is necessary for the app to work

struct WeatherManager {
    
    var delegate: WeatherProtocol?
    
    let weatherURLTemplate = "https://api.openweathermap.org/data/2.5/weather?APPID=\(apiKey)&units=metric&"
    
    func getWeather (cityName: String?, lat: Double?, lon: Double?) {
        if cityName != nil {
            let weatherURL = weatherURLTemplate+"q=\(cityName!)"
            performURLRequest(http: weatherURL)
        } else {
            let weatherURL = weatherURLTemplate+"lat=\(lat!)&lon=\(lon!)"
            performURLRequest(http: weatherURL)
        }
        
    }
    
    func performURLRequest (http: String) {
        
        //1.Create a URL Object
        let url = URL(string: http)
        
        //2.Create a URL Session
        let session = URLSession(configuration: .default)
        
        //3.Give the Session a Task
        let task = session.dataTask(with: url!) { (data, urlResponse, error) in
        //the completionHandler is basically a reciever of potential data/response/error once the task completes.
            
            if error != nil {
                self.delegate?.errorFailed(error!)
                return
            }
            
            if let safeData = data {
                if let weather = self.parseJSON(weatherData: safeData) {
                    self.delegate?.updateUI(weather)
                }
            }
        }
        
        //4.Start the Task
        task.resume() //to initiate the task above.
    }
    
    func parseJSON(weatherData: Data) -> WeatherObject? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let iconID = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherObject(iconID: iconID, cityName: name, temperature: temp)
            return weather
            
        } catch {
            self.delegate?.errorFailed(error)
            return nil
        }
    }
}
