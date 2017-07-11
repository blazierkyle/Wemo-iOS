//
//  UIViewController+Extensions.swift
//  Destination
//
//  Created by Kyle Blazier on 2/18/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: - Execute closure after delay
    func delay(seconds : Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            closure()
        }
    }
    
    // MARK: - Get App Delegate (typically to grab the Core Data stack variables)
    func appDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    // MARK: - Utility function to handle logging
    func logMessage(message: String?, dictionary: [String:Any]? = nil, logAnalyticEvent: Bool = true, sourceName: String = "") {
        Utility.shared.logMessage(message: message, dictionary: dictionary, sourceName: sourceName)
    }
    
    // MARK: - Utility function to present actionable alerts and popups
    func presentAlert(alertTitle : String?, alertMessage : String, cancelButtonTitle : String = "OK", cancelButtonAction : (()->())? = nil, okButtonTitle : String? = nil, okButtonAction : (()->())? = nil, thirdButtonTitle : String? = nil, thirdButtonAction : (()->())? = nil) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        if let okAction = okButtonTitle {
            alert.addAction(UIAlertAction(title: okAction, style: .default, handler: { (action) in
                okButtonAction?()
            }))
            
            if let thirdButton = thirdButtonTitle {
                alert.addAction(UIAlertAction(title: thirdButton, style: .default, handler: { (action) in
                    thirdButtonAction?()
                }))
            }
        }
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel, handler: { (action) in
            cancelButtonAction?()
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showPopup(message : String) {
        let popup = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        self.present(popup, animated: true, completion: {
            
        })
        self.perform(#selector(hidePopup), with: nil, afterDelay: 1.0)
    }
    
    func hidePopup() {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
}

public extension UIColor {
    convenience init(hexString:String) {
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
}

extension NSDate {
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func isSameDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    // returns true if there is the passed # of hours or greater between the date and now
    func hoursBetweenDates(toDate: Date, hours : Int) -> Bool {
        
        let greg = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)!
        
        var comp = DateComponents()
        
        comp.hour = hours
        
        let end = greg.date(byAdding: comp, to:toDate, options:[])!
        
        if self.isGreaterThanDate(dateToCompare: end as NSDate) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func startOfMonth() -> Date? {
        
        let cal = Calendar.current
        
        let dateComps = cal.dateComponents([.year, .month], from: self as Date)
        
        return cal.date(from: dateComps)
        
    }
    
}

extension Date {
    
    
    func dateString() -> String {
        
        Utility.shared.dateFormatter.dateStyle = .short
        Utility.shared.dateFormatter.timeStyle = .short
        return Utility.shared.dateFormatter.string(from: self)
        
    }
}
