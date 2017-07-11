//
//  WemoDeviceCell.swift
//  WeMo
//
//  Created by Kyle Blazier on 12/18/15.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import UIKit

class WemoDeviceCell: UITableViewCell {
    
    @IBOutlet weak var deviceSwitch: UISwitch!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Add target to device switch
        deviceSwitch.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
        
        spinner.hidesWhenStopped = true
        
        wemoDeviceSetup()
    }
    
	var wemoDevice: WemoDevice? {
		didSet {
            // Check if cell is setup - if so, setup for this device
            if deviceNameLabel != nil && deviceSwitch != nil {
                wemoDeviceSetup()
            }
        }
    }
    
    
    func wemoDeviceSetup() {
        
        guard let wemoDevice = wemoDevice else {
            return
        }
    
        // Set device name label
        self.deviceNameLabel.text = wemoDevice.name ?? "Unknown Device Name"
        
        // Show activity indicator
        spinner.startAnimating()
        
        // Fetch current state of the device
        wemoDevice.updateState { (state) -> () in
            
            DispatchQueue.main.async {
                
                // Update switch according to current state
                self.deviceSwitch.isEnabled = state != .unknown
                self.deviceSwitch.isOn = state != .off
                
                // Hide activitiy indicator
                self.spinner.stopAnimating()
            }
        }
	}
	
	func toggleSwitch() {
        
        guard let wemoDevice = wemoDevice else {return}
        
        // Show activity indicator
        spinner.startAnimating()
        
		if self.deviceSwitch.isOn {
            
            wemoDevice.turnOn(completion: { (success) in
                
                // Hide activitiy indicator
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                
            })
		} else {
            
            wemoDevice.turnOff(completion: { (success) in
                
                // Hide activitiy indicator
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
            
            })
        }
	}

}
