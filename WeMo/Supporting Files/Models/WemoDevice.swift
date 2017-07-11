//
//  WemoDevice.swift
//  WeMo
//
//  Created by Sachin on 12/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

enum WemoState {
	case on
	case off
	case unknown
}

class WemoDevice: NSObject {
	var ipAddress: String = ""
	var macAddress: String = ""
	var state: WemoState
	var name: String?
	
	override init() {
		ipAddress = ""
		macAddress = ""
		state = .unknown
		
		super.init()
	}
	
	convenience init(request: WemoScannerRequest) {
		self.init()
		if let ip = request.ipAddress, let mac = request.macAddress {
			ipAddress = ip
			macAddress = mac
		}
		updateState(completion: nil)
	}
    
    convenience init(ipAddress: String, macAddress: String) {
        self.init()
        
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        
        updateState(completion: nil)
    }
	
	// MARK: -
    func determinePort(_ completion: ((_ error: Bool) -> ())?) {
		let validPorts = [49154, 49152, 49153, 49155]
        
		for port in validPorts {
			WemoConduit.run("\(ipAddress):\(port)", type: .getName, completion: {
				response, error in
				if error == nil {
					self.ipAddress = "\(self.ipAddress):\(port)"
                    print("SUCCESS: FOUND SWITCH AT PORT: \(port)")
					completion?(false)
                } else {
                    completion?(true)
                }
			})
		}
	}
	
	func updateName(completion: ((String) -> ())?) {
		assert(ipAddress != "")
		WemoConduit.run(ipAddress, type: .getName, completion: {
			response, error in
			if let responseString = response {
				// Note: this is a terrible, hacky way to parse XML
                
                // Make sure the FriendlyName tag is in the response string
                guard responseString.contains("<FriendlyName>") else {
                    // XML returned for some other reason - discard it
                    completion?("")
                    return
                }
                
				let components = responseString.components(separatedBy: "<FriendlyName>")
				let inner = components[1].components(separatedBy: "</FriendlyName>")
				let name = inner[0].replacingOccurrences(of: "&apos;", with: "'")
				self.name = name
				completion?(name)
			} else {
				completion?("")
			}
		})
	}
	
	func updateState(completion: ((WemoState) -> ())?) {
		assert(ipAddress != "")
		WemoConduit.run(ipAddress, type: .getState, completion: {
			response, error in
			if let responseString = response {
				// Note: this is a terrible, hacky way to parse XML
                
                // Make sure the BinaryState tag is in the response string
                guard responseString.contains("<BinaryState>") else {
                    // XML returned for some other reason - discard it
                    completion?(.unknown)
                    return
                }
                
				let components = responseString.components(separatedBy: "<BinaryState>")
				let inner = components[1].components(separatedBy: "</BinaryState>")
				self.state = inner[0] == "1" ? .on : .off
				completion?(self.state)
			} else {
				completion?(.unknown)
			}
		})
	}
	
	func setState(_ state: WemoState, completion: ((Bool) -> ())?) {
		assert(ipAddress != "")
		assert(state != .unknown, "Can't set state to Unknown.")
		let type: WemoConduitRequestType = state == .on ? .setStateOn : .setStateOff
		WemoConduit.run(ipAddress, type: type, completion: {
			response, error in
			self.state = state
			completion?(error == nil)
		})
	}
    
    
    // MARK: - Convenience functions for turning on and off with notifications
    
    func turnOff(completion: ((Bool) -> ())?) {
        
        setState(.off, completion: { (success) in
            
            guard success else {
                // Notify user of error
                Utility.shared.presentNotificationNow(withTitle: "We encountered an error turning off your WeMo Switch '\(self.name ?? "Unknown Device Name")', please open the app and try again.", withBody: nil)
                
                // Call completion block
                completion?(success)
                
                return
            }
            
            Utility.shared.presentNotificationNow(withTitle: "Your WeMo Switch '\(self.name ?? "Unknown Device Name")' was successfully turned off!", withBody: nil)
            
            // Call completion block
            completion?(success)
            
        })
    }
    
    func turnOn(completion: ((Bool) -> ())?) {
        
        setState(.on, completion: { (success) in
            
            guard success else {
                // Notify user of error
                Utility.shared.presentNotificationNow(withTitle: "We encountered an error turning on your WeMo Switch '\(self.name ?? "Unknown Device Name")', please open the app and try again.", withBody: nil)
                
                // Call completion block
                completion?(success)
                
                return
            }
            
            Utility.shared.presentNotificationNow(withTitle: "Your WeMo Switch '\(self.name ?? "Unknown Device Name")' was successfully turned on!", withBody: nil)
            
            // Call completion block
            completion?(success)
            
        })
    }
}
