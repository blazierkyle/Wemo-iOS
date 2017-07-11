//
//  AppDelegate.swift
//  WeMo
//
//  Created by Kyle Blazier on 12/17/15.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    
    var launchedFromNotification = false
    
    var hasHomeScreenLoaded = false

    
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Checking launch options
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            Utility.shared.logMessage(message: "Launched from notification")
            launchedFromNotification = true
        }
        
        // Make AppDelegate the delegate for UserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        // Register for notification settings
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
         
            // Check for errors
            if let error = error {
                print("** ERROR REGISTERING FOR NOTIFICATIONS: \(error.localizedDescription)")
                return
            }
            
            // If not granted, present error
            if !granted {
                print("Notification access not granted")
                
                self.window?.rootViewController?.presentAlert(alertTitle: "Permissions Not Granted", alertMessage: "You have not enabled access for this app to send notifications, please go to settings and allow access.", cancelButtonTitle: "Dismiss", cancelButtonAction: nil, okButtonTitle: "Go to Settings", okButtonAction: {
                    
                    DispatchQueue.main.async {
                        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {return}
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                    
                })
            }
            
        }
        
        // Request access to location
        LocationManager.shared.requestAccess()

		return true
	}

}


// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        window?.rootViewController?.presentAlert(alertTitle: nil, alertMessage: notification.request.content.body)
        
        Utility.shared.logMessage(message: "*** Recieved a notification in the foreground with title: \(notification.request.content.body) ***")
        
        // Reset flag
        launchedFromNotification = false
        
        completionHandler([.sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Make sure that the notification was acted upon, not just dismissed
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            Utility.shared.logMessage(message: "Notification with text: '\(response.notification.request.content.body)' was dismissed.")
            
            // Reset flag
            launchedFromNotification = false
            
            completionHandler()
            return
        }
        
        // Make sure that the home screen has loaded - else don't show the alert
        guard hasHomeScreenLoaded else {
            // Set a variable in Utility to display an alert - this will be checked when a view appears
            Utility.shared.alertMessageToDisplay = response.notification.request.content.body
            
            // Reset flag
            launchedFromNotification = false
            
            Utility.shared.logMessage(message: "*** Recieved a notification with title: \(response.notification.request.content.body) ***")
            
            completionHandler()
            return
        }
        
        if !launchedFromNotification {
            // Not launched from this notification, just display it
            window?.rootViewController?.presentAlert(alertTitle: nil, alertMessage: response.notification.request.content.body)
        } else {
            // Set a variable in Utility to display an alert - this will be checked when a view appears
            Utility.shared.alertMessageToDisplay = response.notification.request.content.body
        }
        
        Utility.shared.logMessage(message: "*** Recieved a notification with title: \(response.notification.request.content.body) ***")
        
        // Reset flag
        launchedFromNotification = false
        
        completionHandler()
        
    }
    
}

