//
//  LocationManager.swift
//  OpenWeather
//
//  Created by Adrian Krupa on 01.09.2015.
//  Copyright (c) 2015 Adrian Krupa. All rights reserved.
//

import CoreLocation
import AddressBookUI

class LocationManager: NSObject, CLLocationManagerDelegate  {
    
    static let instance = LocationManager()
    
    let locationManager = CLLocationManager()
    
    var fun : ((CLLocationCoordinate2D) -> (Void))!

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        if(newLocation.horizontalAccuracy < 2000) {
            manager.stopUpdatingLocation()
            self.fun(newLocation.coordinate)
        }
    }
    
    func getCurrentLocation (f: (CLLocationCoordinate2D) -> Void) {
        fun = f
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
