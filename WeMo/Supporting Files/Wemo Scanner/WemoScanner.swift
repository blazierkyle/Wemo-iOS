//
//  WemoScanner.swift
//  WeMo
//
//  Created by Sachin on 12/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

protocol WemoScannerDelegate {
	func wemoScannerDidDiscoverDevice(_ device: WemoDevice)
	func wemoScannerFinishedScanning()
}

class WemoScanner: NSObject, WemoScannerRequestDelegate {
	var delegate: WemoScannerDelegate?
	
	fileprivate var timer: Timer
	fileprivate var baseIPAddress: String?
	fileprivate var hostIPAddress: Int
	fileprivate var responseCount: Int
	fileprivate var localIPAddress: String? {
		var addresses = [String]()
		
		// http://stackoverflow.com/questions/25626117/how-to-get-ip-address-in-swift
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0  {
            if let firstAddr = ifaddr  {
                
                // For each interface ...
                for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                    let flags = Int32(ptr.pointee.ifa_flags)
                    let addr = ptr.pointee.ifa_addr.pointee
                    
                    // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                    if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                        if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                            
                            // Convert interface address to a human readable string:
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                let address = String(cString: hostname)
                                addresses.append(address)
                            }
                        }
                    }
                }
                
                freeifaddrs(ifaddr)
                
            }
        }
		
//		// Get list of all interfaces on the local machine:
//		var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
//		if getifaddrs(&ifaddr) == 0 {
//			// For each interface ...
//            for (var ptr = ifaddr; ptr != nil; ptr = ptr?.pointee.ifa_next) {
//				let flags = Int32((ptr?.pointee.ifa_flags)!)
//				var addr = ptr?.pointee.ifa_addr.pointee
//				
//				// Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
//				if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
//					if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
//						// Convert interface address to a human readable string:
//						var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//						if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
//							nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//								if let address = String(validatingUTF8: hostname) {
//									addresses.append(address)
//								}
//						}
//					}
//				}
//			}
//			freeifaddrs(ifaddr)
//		}
		
		guard let address = addresses.last else {
			print("Error determining local IP address.")
			return nil
		}
		return address
	}
	
	override init() {
		timer = Timer()
		hostIPAddress = 1
		responseCount = 0
		
		super.init()
		commonInit()
	}
	
	fileprivate func commonInit() {
		guard let ip = localIPAddress else { return }
		let ipComponents = ip.components(separatedBy: ".")
		if let end = ipComponents.last {
			baseIPAddress = ip.replacingOccurrences(of: ".\(end)", with: "")
		}
	}
	
	// MARK: - IP Scanning
	func scan() {
		timer = Timer.scheduledTimer(timeInterval: 0.0005, target: self, selector: #selector(WemoScanner.scanNext), userInfo: nil, repeats: true)
	}
	
	func scanNext() {
		hostIPAddress += 1
		guard let base = baseIPAddress else {
			print("Base IP address is nil.")
			return
		}
		
		let ping = WemoScannerRequest(ipAddress: "\(base).\(hostIPAddress)")
		ping.delegate = self
		ping.start()
	}
	
	// MARK: - WemoScannerRequestDelegate
	internal func wemoScannerRequestLookupDidSucceed(_ request: WemoScannerRequest) {
		// If MAC address matches Belkin pattern, call delegate method
		let wemoMACPattern = "EC:1A:59:(?:[\\d]|[A-F]){2}:(?:[\\d]|[A-F]){2}:(?:[\\d]|[A-F]){2}"
		guard let mac = request.macAddress else { return }
		let regexExpression = try! NSRegularExpression(pattern: wemoMACPattern, options: .caseInsensitive)
		let matches = regexExpression.matches(in: mac, options: [], range: NSMakeRange(0, mac.characters.count))
		if matches.count > 0 {
			let device = WemoDevice(request: request)
            device.determinePort({ (error) in
                if !error {
                    device.updateName(completion: { (_) -> () in
                        self.delegate?.wemoScannerDidDiscoverDevice(device)
                    })
                }
			})
		}
		
		// Debugging
		// print("IP: \(request.ipAddress!), MAC: \(mac)")

		receivedResponse()
	}
	
	internal func wemoScannerRequestLookupDidFail(_ request: WemoScannerRequest) {
		receivedResponse()
	}
	
	// MARK - More
	fileprivate func receivedResponse() {
		responseCount += 1
		if responseCount > 255 {
			timer.invalidate()
			delegate?.wemoScannerFinishedScanning()
		}
	}
}
