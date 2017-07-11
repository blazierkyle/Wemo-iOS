//
//  HomeTableViewController.swift
//  WeMo
//
//  Created by Kyle Blazier on 7/7/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    lazy var scanner = WemoScanner()
    
    var devices = [WemoDevice]()
    
    var spinner: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic TableView Setup
        tableView.backgroundColor = UIColor(white: 0.964, alpha: 1.0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 55
        tableView.register(WemoDeviceCell.self, forCellReuseIdentifier: "WemoDeviceCell")

        title = "WeMo Devices"
        
        // Setup TableView refresh control
        spinner = UIRefreshControl()
        spinner.attributedTitle = NSAttributedString(string: "Pull to refresh!")
        spinner.addTarget(self, action: #selector(updateDeviceStates), for: .valueChanged)
        tableView.backgroundView = spinner
        
        
        // Reload Devices
        reloadDevices()
        
        // Add notification observer for becoming active
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceStates), name: .UIApplicationWillEnterForeground, object: nil)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set flag in App Delegate that this screen has been loaded
        appDelegate()?.hasHomeScreenLoaded = true
    }
    
    // MARK: - Finding WeMo Devices
    func reloadDevices() {
        
        devices.removeAll()
        
        Utility.shared.deviceScanDelegate = self
        
        Utility.shared.findDevices()
        
        // If refresh control is refreshing, stop it
        if self.spinner.isRefreshing {
            DispatchQueue.main.async {
                self.spinner.endRefreshing()
            }
        }
        
        // ** Not currently working, using hardcoded IPs instead **
//        scanner.delegate = self
//        scanner.scan()
        
    }
    
    func updateDeviceStates() {
        
        for device in devices {
            device.updateState(completion: { (state) in
                
                // If refresh control is refreshing, stop it
                if self.spinner.isRefreshing {
                    DispatchQueue.main.async {
                        self.spinner.endRefreshing()
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    // MARK: - TableView DataSource & Delegate
    override func numberOfSections(in table: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let deviceCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as? WemoDeviceCell, devices.count > indexPath.row else {
            return UITableViewCell()
        }
        deviceCell.wemoDevice = devices[indexPath.row]
        deviceCell.selectionStyle = .none
        return deviceCell
    }

}

// MARK: - WemoScannerDelegate
extension HomeTableViewController: WemoScannerDelegate {
    
    func wemoScannerDidDiscoverDevice(_ device: WemoDevice) {
        
        let devicesMatchMacAddress = devices.filter({$0.macAddress == device.macAddress})
        
        guard devicesMatchMacAddress.count == 0 else {
            print("Duplicate device - not adding to device list")
            return
        }
        
        devices.append(device)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        print("Found a WeMo device, total devices found: \(devices.count)")
        
        // Save this device to User Defaults
        Utility.shared.saveDevice(device: device)
        
    }
    
    func wemoScannerFinishedScanning() {
        print("finished scanning")
    }
}

