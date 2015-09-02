//
//  ViewController.swift
//  OpenWeather
//
//  Created by Adrian Krupa on 01.09.2015.
//  Copyright (c) 2015 Adrian Krupa. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

typealias ServiceResponse = (JSON, NSError?) -> Void

class WeatherViewController: UITableViewController {
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var windDirectionImage: UIImageView!
    @IBOutlet weak var weatherImage: UIImageView!
    
    var pageIndex = NSNotFound
    
    override func viewWillAppear(animated: Bool) {
        clearAllFields()
        setWeatherData()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        setWeatherData()
    }
    
    func clearAllFields() {
        var notKnownString = "---"
        
        self.locationName.text = notKnownString
        self.weatherDescriptionLabel.text = notKnownString
        self.temperatureLabel.text = notKnownString
        self.humidityLabel.text = notKnownString
        self.pressureLabel.text = notKnownString
        self.rainLabel.text = notKnownString
        self.cloudsLabel.text = notKnownString
        self.windLabel.text = notKnownString
        self.windDirectionImage.hidden = true
        self.weatherImage.image = nil
    }
    
    @IBOutlet weak var refresh: UIRefreshControl!
    func setWeatherData() {
        LocationManager.instance.getCurrentLocation { (location) -> Void in
            OpenWeatherManager.instance.getWeather(location) { (data, image, error) -> Void in
                
                self.refreshControl?.endRefreshing()
                var code = data["cod"]
                if error || (data["cod"] != nil && data["cod"].description != "200") {
                    self.clearAllFields()
                    self.locationName.text = "Server error"
                    self.weatherDescriptionLabel.text = "Pull to Refresh"
                } else {
                    
                    self.locationName.text = data["name"].string
                    self.weatherDescriptionLabel.text = data["weather"][0]["description"].string
                    self.temperatureLabel.text = String(format:"%.f℃", data["main"]["temp"].double!)
                    self.humidityLabel.text = String(format:"%.f%%", data["main"]["humidity"].double!)
                    self.pressureLabel.text = String(format:"%.f hPa", data["main"]["pressure"].double!)
                    self.rainLabel.text = String(format:"%.1f mm", data["rain"]["1h"].double ?? 0)
                    self.cloudsLabel.text = String(format:"%.f%%", data["clouds"]["all"].double!)
                    self.windLabel.text = String(format:"%.f km/h", data["wind"]["speed"].double! * 3.6)
                    
                    if let windDir = data["wind"]["deg"].float {
                        var windDirection = windDir * Float(M_PI) / 180 - Float(M_PI_2)
                        self.windDirectionImage.hidden = false
                        self.windDirectionImage.transform = CGAffineTransformMakeRotation(CGFloat(windDirection));
                    } else {
                        self.windDirectionImage.hidden = true
                    }
                    
                    if image != nil {
                        self.weatherImage.image = image
                    }
                }
            }
        }
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data)
            onCompletion(json, error)
        })
        task.resume()
    }	
}

