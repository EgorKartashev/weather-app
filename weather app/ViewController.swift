
import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var iconImage: UIImageView!
    
    
    
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
    }
    

    func startLocationManager(){
        locationManager.requestWhenInUseAuthorization() // запрос на авторизацию
        
        if CLLocationManager.locationServicesEnabled() { // если геолокация включена на тел
            locationManager.delegate = self // делегат срабатывает когда меняется геоположение
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // точно 100 метров
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation() // запускается слижение за местоположением
            
        }
    }
    
    func updateView(){
        self.cityLabel.text = weatherData.name
        self.descriptionLabel.text = DataSource.weatherIDs[weatherData.weather[0].id]
        self.temperatureLabel.text = weatherData.main.temp.description + "º"
        self.iconImage.image = UIImage(named: weatherData.weather[0].icon)
    
    }
    
    
    func updateWeatherInfo(latitude: Double, longitude: Double) {
        let session = URLSession.shared
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longitude.description)&lang=ru&units=metric&appid=262f846b24b00fdb6378d899fd0da8d7") else {return}
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Data task error: \(error!.localizedDescription)")
                return
            }
            
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                print(self.weatherData)
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last{
            updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        }
    }
}
