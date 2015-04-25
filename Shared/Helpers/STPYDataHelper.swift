//
//  STPYDataHelper.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit
import Foundation

class STPYDataHelper: NSObject {
    
    /**
    Gets an NSUserDefaults NSData value and unarchives it
    
    :param: key The NSUserDefaults key
    
    :returns: The object
    */
    class func getObjectForKey(key : String) -> AnyObject? {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(key) as! NSData?
        if data != nil {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data!)
        }
        return nil
    }
    
    /**
    Saves an object as NSData to NSUserDefaults for specified key
    
    :param: object The bool value
    :param: key The NSUserDefaults key
    */
    class func saveDataForKey(object : AnyObject?, key : String) {
        if let object: AnyObject = object {
            let defaults = NSUserDefaults.standardUserDefaults()
            let dataObject = NSKeyedArchiver.archivedDataWithRootObject(object)
            defaults.setObject(dataObject, forKey: key)
            defaults.synchronize()
        }
    }

    /**
    Gets an NSUserDefaults key bool value
    
    :param: key The NSUserDefaults key
    
    :returns: value The bool value
    */
    class func key(key : String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    /**
    Sets an NSUserDefaults key to a bool value
    
    :param: value The bool value
    :param: key The NSUserDefaults key 
    */
    class func keyIs(value : Bool, key : String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(value, forKey: key)
        defaults.synchronize()
    }
}