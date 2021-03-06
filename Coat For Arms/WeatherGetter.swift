//
//  WeatherGetter.swift
//  Coat For Arms
//
//  Created by Carter Yu on 12/11/16.
//  Copyright © 2016 Carter. All rights reserved.
//

import Foundation


protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: NSError)
}


class WeatherGetter {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "38473ddfe636e06e0a2e3a64005a95e8"
    
    private var delegate: WeatherGetterDelegate
    
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherByCity(city: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL)
    }
    
    func getWeatherByCoordinates(latitude latitude: Double, longitude: Double) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL)
    }
    
    private func getWeather(weatherRequestURL: NSURL) {
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 3
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let networkError = error {
                self.delegate.didNotGetWeather(networkError)
            }
            else {
                do {
                    let weatherData = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    let weather = Weather(weatherData: weatherData)
                    self.delegate.didGetWeather(weather)
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetWeather(jsonError)
                }
            }
        }
        
        dataTask.resume()
    }
}