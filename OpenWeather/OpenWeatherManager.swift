//
//  OpenWeatherManager.swift
//  OpenWeather
//
//  Created by Adrian Krupa on 01.09.2015.
//  Copyright (c) 2015 Adrian Krupa. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class OpenWeatherManager: NSObject {
    static let instance = OpenWeatherManager()
    
    let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    let baseImageURL = "http://openweathermap.org/img/w/"
    let apiKey = "422e9924abcbe7bb6b529b3e6c5907f7"
    let units = "metric"
    
    var lastWeatherImageIconName = ""
    
    func getWeather(location: CLLocationCoordinate2D, onCompletion: (JSON, UIImage?, Bool) -> Void) {
        var path = "\(baseURL)?lat=\(location.latitude)&lon=\(location.longitude)&units=\(units)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        println(request)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                println("dataTaskWithRequest error: \(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    onCompletion(nil, nil, true)
                })
            }
            
            if let res = response as? NSHTTPURLResponse {
                var code = res.statusCode
                if code != 200 {
                    println("dataTaskWithRequest HTTP status code: error: \(code)")
                    dispatch_async(dispatch_get_main_queue(), {
                        onCompletion(nil, nil, true)
                    })
                }
            }
            
            let json:JSON = JSON(data: data)
            println("\(json)")
            var image : UIImage? = nil
            if let iconString = json["weather"][0]["icon"].string {
                if iconString != self.lastWeatherImageIconName {
                    self.lastWeatherImageIconName = iconString
                    if let url = NSURL(string:"\(self.baseImageURL)\(iconString).png") {
                        if let data = NSData(contentsOfURL: url){
                            image = UIImage(data: data)
                        }
                    }
                }
            } else {
                self.lastWeatherImageIconName = ""
            }
            dispatch_async(dispatch_get_main_queue(), {
                onCompletion(json, image, false)
            })
        })
        task.resume()
        
    }
}
