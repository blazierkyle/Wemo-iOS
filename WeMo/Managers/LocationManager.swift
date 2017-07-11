//
//  LocationManager.swift
//  Destination
//
//  Created by Kyle Blazier on 1/26/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    
    lazy var geocoder = CLGeocoder()
    
    override init() {
        
        super.init()
        
        manager.delegate = self
        
    }
    
    func requestAccess() {
        
        // Request always access
        manager.requestAlwaysAuthorization()
        
        // Setup geofence for the home
        setupGeofenceForHome()
    }
    
    func setupGeofenceForHome() {
        
        // Start monitoring for a region that surrounds the home
        let geofenceRegion = CLCircularRegion(center: Constants.geofenceCenterCoordinate, radius: Constants.geofenceRadius, identifier: Constants.geofenceKey)
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        manager.startMonitoring(for: geofenceRegion)
        
        Utility.shared.logMessage(message: "Started to monitor for the geofence around campus")
        Utility.shared.logMessage(message: "Monitoring for: \(manager.monitoredRegions) regions")
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined, .restricted, .denied:
            Utility.shared.logMessage(message: "Access not granted", sourceName: "Location Manager")
        case .authorizedAlways:
            Utility.shared.logMessage(message: "Location authorized always!", sourceName: "Location Manager")
        default:
            Utility.shared.logMessage(message: "Unknown location access", sourceName: "Location Manager")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        // Handle geofence crossing
        Utility.shared.geofenceCrossed(geofenceID: region.identifier, entered: true)
        
        Utility.shared.logMessage(message: "Entered region", sourceName: "Location Manager")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        // Handle geofence crossing
        Utility.shared.geofenceCrossed(geofenceID: region.identifier, entered: false)
        
        Utility.shared.logMessage(message: "Exited region", sourceName: "Location Manager")

    }
    
}
