//
//  Constants.swift
//  WeMo
//
//  Created by Kyle Blazier on 7/6/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import Foundation
import CoreLocation

class Constants {
    
    // MARK: - IP Addresses for Wemo Devices

    /*** 
        NOTE: Using hardcoded IP addresses since we are unable to 
        scan to detect WeMo devices using WemoScanner classes. This
        is a WORK IN PROGRESS and I'm unsure of how this will work
        with multiple devices.
    ***/
    
    // Public IP Address (to connect to device outside of local network)
    static let wemoDevicePublic1 = WemoDevice(ipAddress: "XXX.XXX.XXX.XX", macAddress: "XX:XX:XX:XX:XX:XX")
    
    // Array containing all of the WeMo devices
    static let wemoDeviceArray = [Constants.wemoDevicePublic1]
    
    
    // MARK: - Constant Keys
    static let userDefaultsSettingsKey = "UserDictionarySettings"
    static let geofenceKey = "HomeGeofenceKey"
    static let savedDevicesKey = "SavedDevicesKey"
    static let deviceMacAddressKey = "DeviceMacAddressKey"
    static let deviceIpAddressKey = "DeviceIpAddressKey"
    static let deviceNameKey = "DeviceNameKey"
    static let geofenceCenterCoordinateLatitudeKey = "GeofenceCenterCoordinateLatitudeKey"
    static let geofenceCenterCoordinateLongitudeKey = "GeofenceCenterCoordinateLongitudeKey"
    static let geofenceRadiusKey = "GeofenceRadiusKey"
    static let geofenceTurnOnTimeKey = "GeofenceTurnOnTimeKey"
    
    
    // MARK: - Notifications
    static let foundDeviceNotification = Notification.Name("FoundDeviceNotification")
    
    
    // MARK: - Geofencing variables/functions
    static var geofenceCenterCoordinate: CLLocationCoordinate2D {
        get {
            // Return saved value from user defaults if one exists, otherwise use a default coordinate
            guard let latitude = UserDefaults.standard.object(forKey: Constants.geofenceCenterCoordinateLatitudeKey) as? Double, let longitude = UserDefaults.standard.object(forKey: Constants.geofenceCenterCoordinateLongitudeKey) as? Double else {
                return CLLocationCoordinate2D(latitude: 37.331991, longitude: -122.031137) // Defaults to Apple's Campus' Coordinates
            }
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
        }
        set {
            // Save this value in user defaults
            UserDefaults.standard.set(Double(newValue.latitude), forKey: Constants.geofenceCenterCoordinateLatitudeKey)
            UserDefaults.standard.set(Double(newValue.longitude), forKey: Constants.geofenceCenterCoordinateLongitudeKey)
        }
    }

    static var geofenceRadius: Double {
        get {
            // Return saved value from user defaults if one exists, otherwise use a default value
            return UserDefaults.standard.object(forKey: Constants.geofenceRadiusKey) as? Double ?? 100.0 // Defaults to 100m
        }
        set {
            // Save this value in user defaults
            UserDefaults.standard.set(newValue, forKey: Constants.geofenceRadiusKey)
        }
    }

    static var turnOnTime: Double {
        get {
            // Return saved value from user defaults if one exists, otherwise use a default value
            return UserDefaults.standard.object(forKey: Constants.geofenceTurnOnTimeKey) as? Double ?? 17.0 // Defaults to 5 PM
        }
        set {
            // Save this value in user defaults
            UserDefaults.standard.set(newValue, forKey: Constants.geofenceTurnOnTimeKey)
        }
    }
    
}
