//
//  ViewController.swift
//  Coat For Arms
//
//  Created by Carter Yu on 12/11/16.
//  Copyright © 2016 Carter. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController,WeatherGetterDelegate,CLLocationManagerDelegate,UITextFieldDelegate
{
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var getLocationWeatherButton: UIButton!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var getCityWeatherButton: UIButton!
    
    let locationManager = CLLocationManager()
    var weather: WeatherGetter!
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather = WeatherGetter(delegate: self)
        
        cityLabel.text = ""
        cityLabel.textColor = UIColor.blueColor()
        weatherLabel.text = "Where are you? :)"
        temperatureLabel.text = "0°"
        windLabel.text = "0 m/s"
        rainLabel.text = "No rain yet!"
        humidityLabel.text = "0%"
        cityTextField.text = ""
        cityTextField.placeholder = "Alternatively - enter city name!"
        cityTextField.delegate = self
        cityTextField.enablesReturnKeyAutomatically = true
        getCityWeatherButton.enabled = false
        
        getLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func getWeatherForLocationButtonTapped(sender: UIButton) {
        setWeatherButtonStates(false)
        getLocation()
        
    }
    
    @IBAction func getWeatherForCityButtonTapped(sender: UIButton) {
        guard let text = cityTextField.text where !text.trimmed.isEmpty else {
            return
        }
        setWeatherButtonStates(false)
        weather.getWeatherByCity(cityTextField.text!.urlEncoded)
        let CatSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("lol", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: CatSound)
            audioPlayer.prepareToPlay()
        } catch {
            print("Problem in getting File")
        }
        audioPlayer.play()
    }
    
    func setWeatherButtonStates(state: Bool) {
        getLocationWeatherButton.enabled = state
        getCityWeatherButton.enabled = state
    }
    
    
    func didGetWeather(weather: Weather) {
        dispatch_async(dispatch_get_main_queue()) {
            self.cityLabel.text = weather.city
            self.weatherLabel.text = weather.weatherDescription
            self.temperatureLabel.text = "\(Int(round(weather.tempFahrenheit)))°"
            self.windLabel.text = "\(weather.windSpeed) m/s"
            if let rain = weather.rainfallInLast3Hours {
                self.rainLabel.text = "\(rain) mm"
            }
            else {
                self.rainLabel.text = "None"
            }
            self.humidityLabel.text = "\(weather.humidity)%"
            self.getLocationWeatherButton.enabled = true
            self.getCityWeatherButton.enabled = self.cityTextField.text?.characters.count > 0
        }
    }
    
    func didNotGetWeather(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showSimpleAlert(title: "Can't get the weather",
                message: "API isn't responding. Maybe you reached the limit?")
            self.getLocationWeatherButton.enabled = true
            self.getCityWeatherButton.enabled = self.cityTextField.text?.characters.count > 0
        }
        print("didNotGetWeather error: \(error)")
    }
    
    
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showSimpleAlert(
                title: "Please turn on location services",
                message: "This app needs location services in order to report the weather " +
                    "for your current location.\n" +
                "Go to Settings → Privacy → Location Services and turn location services on."
            )
            getLocationWeatherButton.enabled = true
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .AuthorizedWhenInUse else {
            switch authStatus {
            case .Denied, .Restricted:
                let alert = UIAlertController(
                    title: "Location services for this app are disabled",
                    message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".",
                    preferredStyle: .Alert
                )
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let openSettingsAction = UIAlertAction(title: "Open Settings", style: .Default) {
                    action in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(openSettingsAction)
                presentViewController(alert, animated: true, completion: nil)
                getLocationWeatherButton.enabled = true
                return
                
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("you done goofed kid")
            }
            
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        weather.getWeatherByCoordinates(latitude: newLocation.coordinate.latitude,
            longitude: newLocation.coordinate.longitude)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showSimpleAlert(title: "Can't fetch location :(",
                message: "Please make sure your GPS is working!")
        }
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(
                range,
                withString: string).trimmed
            getCityWeatherButton.enabled = prospectiveText.characters.count > 0
            return true
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.text = ""
        
        getCityWeatherButton.enabled = false
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getWeatherForCityButtonTapped(getCityWeatherButton)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func showSimpleAlert(title title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .Default,
            handler: nil
        )
        alert.addAction(okAction)
        presentViewController(
            alert,
            animated: true,
            completion: nil
        )
    }
    
}


extension String {
    var urlEncoded: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())!
    }
    var trimmed: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
}
