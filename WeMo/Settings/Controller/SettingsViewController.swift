//
//  SettingsViewController.swift
//  WeMo
//
//  Created by Kyle Blazier on 7/10/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var radiusTextField: UITextField!
    
    @IBOutlet weak var turnOnTimeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var geofenceCenterPlacemark: MKPlacemark?
    
    var dataChanged = false {
        didSet {
            saveButton.isEnabled = dataChanged
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set current point, radius and time on
        let placemark = MKPlacemark(coordinate: Constants.geofenceCenterCoordinate)
        
        map.addAnnotation(placemark)
        
        geofenceCenterPlacemark = placemark
        
        radiusTextField.text = "\(Constants.geofenceRadius)"
        turnOnTimeTextField.text = "\(Constants.turnOnTime)"
        
        saveButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Add gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 1.0
        map.addGestureRecognizer(gestureRecognizer)
        
        longPressGestureRecognizer = gestureRecognizer
        
        // Add textfield notification
        NotificationCenter.default.addObserver(self, selector: #selector(setDataWasChanged), name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Remove gesture recognizer
        guard let longPressGestureRecognizer = longPressGestureRecognizer else {return}
        map.removeGestureRecognizer(longPressGestureRecognizer)
        
        // Remove textfield notification
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Center the map and zoom it
        map.setCenter(Constants.geofenceCenterCoordinate, animated: false)
        
        guard let geofenceCenterPlacemark = geofenceCenterPlacemark else {return}
        map.showAnnotations([geofenceCenterPlacemark], animated: true)
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Make sure the gesture is beginning
        guard gestureRecognizer.state == .began else {return}
        
            // Get the coordinate being long pressed
            let touchPoint = gestureRecognizer.location(in: self.map)
            
            let coordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
        
        // Ask for confirmation
        presentAlert(alertTitle: "Update Geofence Center?", alertMessage: "Are you sure you'd like to update your geofence center and remove the old location?", cancelButtonTitle: "Cancel", cancelButtonAction: nil, okButtonTitle: "Yes, update location", okButtonAction: {
            
            DispatchQueue.main.async {
                
                // Remove previous annotation
                if let previousPlacemark = self.geofenceCenterPlacemark {
                    self.map.removeAnnotation(previousPlacemark)
                }
                
                // Add new annotation
                let newGeofencePlacemark = MKPlacemark(coordinate: coordinate)
                self.map.addAnnotation(newGeofencePlacemark)
                
                self.geofenceCenterPlacemark = newGeofencePlacemark
                
            }
            
            self.dataChanged = true
            
        })
    
    }
    
    func setDataWasChanged() {
        dataChanged = true
    }

    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        // Ask for confirmation
        presentAlert(alertTitle: "Update all fields?", alertMessage: "Are you sure you want to update all fields?", cancelButtonTitle: "Cancel", cancelButtonAction: nil, okButtonTitle: "Yes, change fields", okButtonAction: { 
            
            // Get required values
            guard let radiusText = self.radiusTextField.text, let radius = Double(radiusText), let turnOnText = self.turnOnTimeTextField.text, let turnOnTime = Double(turnOnText), let point = self.geofenceCenterPlacemark?.coordinate else {
            
                self.presentAlert(alertTitle: "Error", alertMessage: "Mising required fields")
                
                return
            }
            
            // Save radius
            Constants.geofenceRadius = radius
            
            // Save turn on time
            Constants.turnOnTime = turnOnTime
            
            // Save Point
            Constants.geofenceCenterCoordinate = point
            
            // Update geofence
            LocationManager.shared.setupGeofenceForHome()
            
            // Disable save button
            DispatchQueue.main.async {
                self.saveButton.isEnabled = false
            }
            
        })
        
    }

}

extension SettingsViewController: MKMapViewDelegate {
    
}
