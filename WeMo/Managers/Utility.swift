//
//  Utility.swift
//  WeMo
//
//  Created by Kyle Blazier on 7/7/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import Foundation
import UserNotifications

class Utility {
    
    static let shared = Utility()

    var alertMessageToDisplay: String?
    
    lazy var dateFormatter = DateFormatter()
    
    var devices = [WemoDevice]()
    
    var deviceScanDelegate: WemoScannerDelegate?
    

    
    // MARK: - Simplistic message logging - easily disablable from one location
    func logMessage(message: String?, dictionary: [String:Any]? = nil, sourceName: String = "") {
        print("*** Begin log statement in \(sourceName) ***")
        if let message = message {
            print(message)
        }
        if let dictionary = dictionary {
            print(dictionary)
        }
        print("*** End log statement \(sourceName) ***")
    }
    
    
    // MARK: - Finding WeMo Switches
    func findDevices() {
        
        devices.removeAll()
        
        // Get hardcoded WeMo Device IP Addresses from Constants and try to determine the port for all of them
        for device in Constants.wemoDeviceArray {
            
            device.determinePort({ (error) in
                
                // If no error, get device name
                guard !error else {
                    print("Error determining port")
                    return
                }
                    
                device.updateName(completion: { (name) -> () in
                    
                    guard let _ = name else {return}
                    
                    self.deviceScanDelegate?.wemoScannerDidDiscoverDevice(device)
                    
                })
                
            })
            
        }
        
    }
    
    
    // MARK: - Persisting Devices in UserDefaults
    func saveDevice(device: WemoDevice) {
        
        var devices = [String: [String:String]]()
        
        // Check if we have an existing dictionary
        if let savedDevices = UserDefaults.standard.value(forKey: Constants.savedDevicesKey) as? [String: [String:String]] {
            
            // Existing devices, set saved devices to variable devices (will add device to the dictionary either way below)
            devices = savedDevices
        }
        
        // Add the device to the dictionary
        devices[device.macAddress] = createDeviceDict(fromDevice: device)
        
        // Save the dictionary
        UserDefaults.standard.setValue(devices, forKey: Constants.savedDevicesKey)
        
        print("Saved devices count = \(devices.count)")
        
    }
    
    func getSavedDevices() -> [WemoDevice]? {
        
        // Try to get array of device dictionaries from defaults
        guard let savedDevices = UserDefaults.standard.value(forKey: Constants.savedDevicesKey) as? [String: [String:String]] else {
            print("Couldn't retrieve any saved devices")
            return nil
        }
        
        var devices = [WemoDevice]()
        
        // Have saved devices, now convert to WemoDevice models
        for device in savedDevices {
            
            // Create a WemoDevice for this device
            guard let device = createDevice(fromDeviceDict: device.value, withMacAddress: device.key) else {continue}
            
            devices.append(device)
            
        }
        
        print("Retrieved \(savedDevices.count) devices")
        
        return devices.count > 0 ? devices : nil
        
    }
    
    
    // MARK: - Utility Conversion Methods for Setting/Getting Device Keys from a Dictionary
    func createDeviceDict(fromDevice device: WemoDevice) -> [String:String] {
        
        return [Constants.deviceIpAddressKey: device.ipAddress, Constants.deviceNameKey: device.name ?? "Unknown Name"]
        
    }
    
    func createDevice(fromDeviceDict deviceDict: [String:String], withMacAddress macAddress: String) -> WemoDevice? {
        
        guard let ipAddress = deviceDict[Constants.deviceIpAddressKey] else {return nil}
        
        let device = WemoDevice(ipAddress: ipAddress, macAddress: macAddress)
        
        device.name = deviceDict[Constants.deviceNameKey]
        
        return device
    }
    
    
    // MARK: - Present Local notification
    func presentNotificationNow(withTitle title: String, withBody body: String?) {
        
        let content = UNMutableNotificationContent()
        content.body = title
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: generateUUID(), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            
            if let error = error {
                // Error
                Utility.shared.logMessage(message: "Error creating local notification: \(error.localizedDescription)")
                return
            }
            
            Utility.shared.logMessage(message: "Successfully scheduled a notification after reaching a destination")
            
        })
        
    }

    
    // MARK: - Generate UUIDs
    func generateUUID() -> String {
        return NSUUID().uuidString
    }
    
    
    // MARK: - Geofencing
    func geofenceCrossed(geofenceID: String, entered: Bool) {
        
        // Currently only one region - just check if the ID matches and check if it's an entry
        guard geofenceID == Constants.geofenceKey, entered == true else {return}
        
        // If after 5 PM turn on the switch on
        dateFormatter.dateFormat = "HH.mm"
        dateFormatter.timeZone = TimeZone.current
        
        guard let currentTimeString = Double(dateFormatter.string(from: Date())) else {
            print("Couldn't convert time to Float")
            return
        }
        
        print("Date as a float is: \(currentTimeString)")
        
        // Check if the current time is after the turn on time
        guard currentTimeString >= Constants.turnOnTime else {
            print("Not after turn on time - don't turn on lights")
            return
        }
        
        // After turn on time - turn switch on
        
        // Iterate over saved devices and turn them on
        guard let savedDevices = getSavedDevices() else {
            print("*** ERROR: No saved devices to turn on!")
            return
        }
        
        for device in savedDevices {
            device.turnOn(completion: nil)
        }
        
    }
    
}

// MARK: - User Details Object stored in defaults
extension Utility {
    
    func getUserDetailsObject() -> [String:AnyObject]? {
        return UserDefaults.standard.dictionary(forKey: Constants.userDefaultsSettingsKey) as [String : AnyObject]?
    }

    func setUserDetailsObject(userDetails: [String:AnyObject]) {
        UserDefaults.standard.set(userDetails, forKey: Constants.userDefaultsSettingsKey)
    }

    func addValueToUserDetailsObject(key : String, value : AnyObject) {
        if var userDetails = getUserDetailsObject() {
            userDetails[key] = value
            setUserDetailsObject(userDetails: userDetails)
        } else {
            // dictionary doesn't exist - create it now then save
            var newUserDetails = [String:AnyObject]()
            newUserDetails[key] = value
            setUserDetailsObject(userDetails: newUserDetails)
        }
    }

    func getValueFromUserDetailsObject(key: String) -> AnyObject? {
        guard let dict = getUserDetailsObject() else {return nil}
        return dict[key]
    }

    func getBoolFromUserDetailsObject(key: String) -> Bool {
        guard let dict = getUserDetailsObject() else {return false}
        guard let value = dict[key] as? Bool else {return false}
        return value
    }

    func removeValueFromUserDetailsObject(key: String) {
        guard var dict = getUserDetailsObject() else {return}
        dict.removeValue(forKey: key)
        setUserDetailsObject(userDetails: dict)
    }

}


