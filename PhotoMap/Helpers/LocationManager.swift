//
//  LocationManager.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/17/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import CoreLocation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol LocationManagerDelegate: class {
    func bestEffortLocationFound(_ location: CLLocation)
//    func foundInitialLocation(location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    struct LocationTimeInterval {
        static let timeout = TimeInterval(30)
        static let restartAfter = TimeInterval(60)
    }
    
    // MARK: - Properties
    weak var delegate: LocationManagerDelegate?
    
    lazy var locationManager = CLLocationManager()
    var bestEffortAtLocation: CLLocation?
    var timer: Timer?
    
    // MARK: - Init
    init(locationAccuracy: CLLocationAccuracy? = nil) {
        super.init()
        locationManager.delegate = self
        // The default desired accuracy is fairly low since we are just trying to 
        // get a general area to find photos
        locationManager.desiredAccuracy =
            locationAccuracy != nil ? locationAccuracy! : kCLLocationAccuracyHundredMeters
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        checkLocationAuthorizationStatus()
    }
    
    deinit {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
        if timer != nil {
            cancelTimer()
        }
        
        bestEffortAtLocation = nil
    }
    
    // MARK: - Actions
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        dlog("Updating location.")
        locationManager.startUpdatingLocation()
        
        // Stop the Core Location Manager after delay
        cancelTimer()
        timer = Timer.scheduledTimer(
            timeInterval: LocationTimeInterval.timeout,
            target: self,
            selector: #selector(LocationManager.stopUpdatingLocationWithDelayedRestart),
            userInfo: nil, repeats: false)
    }
    
    func stopUpdatingLocationWithDelayedRestart() {
        // The location update is suspended to limit power consumption
        locationManager.stopUpdatingLocation()
        cancelTimer()
        timer = Timer.scheduledTimer(
            timeInterval: LocationTimeInterval.restartAfter,
            target: self,
            selector: #selector(LocationManager.startUpdatingLocation),
            userInfo: nil, repeats: false)
    }
    
    // Add NSLocationWhenInUseUsageDescription to info.plist
    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            startLocationServices()
            dlog("Starting location services.")
        case .denied, .restricted:
            dlog("Location services not available.")
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            startLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            dlog("No valid location")
            return
        }
        // Test that it isn't an invalid measurement
        if location.horizontalAccuracy < 0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test if the location is cached
        let locationAge = -(location.timestamp.timeIntervalSinceNow)
        if locationAge > 5.0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test if the new location is more accurate
        if bestEffortAtLocation == nil || bestEffortAtLocation?.horizontalAccuracy > location.horizontalAccuracy {
            bestEffortAtLocation = location
            
//            delegate?.foundInitialLocation(location)
            
            // Test if it meets the desired accuracy
            if location.horizontalAccuracy <= locationManager.desiredAccuracy {
                // The measurement satisfies the requirement.
                if let bestEffortLocation = bestEffortAtLocation {
                    delegate?.bestEffortLocationFound(bestEffortLocation)
                }
                locationManager.stopUpdatingLocation()
                cancelTimer()
                dlog("Best effort location: \(bestEffortAtLocation)")
            }
        }
    }
}

