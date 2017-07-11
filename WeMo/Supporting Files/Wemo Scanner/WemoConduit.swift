//
//  WemoConduit.swift
//  WeMo
//
//  Created by Sachin on 12/18/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

enum WemoConduitRequestType {
	case getState
	case getSignalStrength
	case getName
	case setStateOn
	case setStateOff
}

class WemoConduit: NSObject {
	fileprivate class func actionStringForRequestType(_ type: WemoConduitRequestType) -> String {
		switch type {
		case .getState:
			return "GetBinaryState"
		case .getSignalStrength:
			return "GetSignalStrength"
		case .getName:
			return "GetFriendlyName"
		case .setStateOff, .setStateOn:
			return "SetBinaryState"
		}
	}
	
	class func run(_ ipAddress: String, type: WemoConduitRequestType, completion: @escaping (NSString?, NSError?) -> ()) {
		let actionString = actionStringForRequestType(type)
		
		// Set up request
		let url = URL(string: "http://\(ipAddress)/upnp/control/basicevent1")!
		let session = URLSession.shared
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		// Set headers
		request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
		request.addValue("\"urn:Belkin:service:basicevent:1#\(actionString)\"", forHTTPHeaderField: "SOAPACTION")
		
		// Determine body to send
		var parameterValueString = ""
		switch type {
			case .setStateOn, .getState: parameterValueString = "1"
			case .setStateOff, .getSignalStrength: parameterValueString = "0"
			default: parameterValueString = ""
		}
		let parameterKey = actionString.replacingOccurrences(of: "Get", with: "").replacingOccurrences(of: "Set", with: "")
		let dataString = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:\(actionString) xmlns:u=\"urn:Belkin:service:basicevent:1\"><\(parameterKey)>\(parameterValueString)</\(parameterKey)></u:\(actionString)></s:Body></s:Envelope>"
		request.httpBody = dataString.data(using: String.Encoding.utf8)
		
		// Perform request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check for errors
            if let error = error {
                completion(nil, error as NSError)
                return
            }
			
			guard let data = data, let _ = response else {
				completion(nil, nil)
				return
			}
			
			let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            
			completion(dataString, nil)
		}
		
		task.resume()
	}
}
