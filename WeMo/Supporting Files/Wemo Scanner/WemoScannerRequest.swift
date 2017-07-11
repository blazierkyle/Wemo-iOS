//
//  WemoScannerRequest.swift
//  WeMo
//
//  Created by Sachin on 12/17/15.
//  Copyright © 2015 Sachin Patel. All rights reserved.
//

import UIKit

protocol WemoScannerRequestDelegate {
	func wemoScannerRequestLookupDidSucceed(_ request: WemoScannerRequest)
	func wemoScannerRequestLookupDidFail(_ request: WemoScannerRequest)
}

class WemoScannerRequest: NSObject, SimplePingDelegate {
	var delegate: WemoScannerRequestDelegate?
	
	fileprivate var validationPing: SimplePing?
	var ipAddress: String?
	var macAddress: String?
	
	override init() {
		super.init()
	}
	
	convenience init(ipAddress: String) {
		self.init()
		self.ipAddress = ipAddress
	}
	
	func start() {
		assert(ipAddress != nil, "IP address must be non-nil.")
		validationPing = SimplePing(hostName: ipAddress)
		validationPing?.delegate = self
		validationPing?.start()
		perform(#selector(WemoScannerRequest.timeout), with: nil, afterDelay: 1)
	}
	
	func timeout() {
		delegate?.wemoScannerRequestLookupDidFail(self)
	}
	
	// MARK: - SimplePing Delegate
	func simplePing(_ pinger: SimplePing!, didStartWithAddress address: Data!) {
		pinger.send(with: nil)
	}
	
	func simplePing(_ pinger: SimplePing!, didFailWithError error: Error!) {
		// Validation failed, device with IP doesn't exist
		delegate?.wemoScannerRequestLookupDidFail(self)
	}
	
	func simplePing(_ pinger: SimplePing!, didFailToSendPacket packet: Data!, error: Error!) {
		// Not connected to network
		delegate?.wemoScannerRequestLookupDidFail(self)
	}
	
	func simplePing(_ pinger: SimplePing!, didReceivePingResponsePacket packet: Data!) {
		macAddress = MacAddressHelper.macAddress(forIPAddress: ipAddress!)
		delegate?.wemoScannerRequestLookupDidSucceed(self)
	}
}
