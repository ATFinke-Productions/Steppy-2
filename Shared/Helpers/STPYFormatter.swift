//
//  STPYFormatter.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 2/6/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit

class STPYFormatter {
    
    class var sharedInstance : STPYFormatter {
        struct Static {
            static let instance : STPYFormatter = STPYFormatter()
        }
        return Static.instance
    }
    
    let dateFormatter = NSDateFormatter()
    let numberFormatter = NSNumberFormatter()
    let percentFormatter = NSNumberFormatter()
    let dateIntervalFormatter = NSDateIntervalFormatter()
    let lengthFormatter = NSLengthFormatter()
    
    init() {
        numberFormatter.usesGroupingSeparator = true
        dateIntervalFormatter.dateTemplate = "MMMM d"
        lengthFormatter.unitStyle = .Long
        percentFormatter.numberStyle = .PercentStyle
    }
    
    //MARK: Getting Objects
    
    /**
    Gets the date from a string with date format
    
    - parameter key: The date string
    - parameter format: The date format
    
    - returns: The date
    */
    func date(key : String, format : String) -> NSDate {
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(key)!
    }
    
    //MARK: Getting Strings
    
    /**
    Gets the formatted string from a date with date format
    
    - parameter date: The date
    - parameter format: The date format
    
    - returns: The formatted string
    */
    func string(date : NSDate, format : String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
    }
    
    /**
    Gets the formatted string for the interval between dates
    
    - parameter startDate: The start date
    - parameter end: The end date
    
    - returns: The formatted string
    */
    func string(startDate : NSDate, endDate : NSDate) -> String {
        return dateIntervalFormatter.stringFromDate(startDate, toDate: endDate)
    }
    
    /**
    Gets the formatted string for a number
    
    - parameter number: The number
    
    - returns: The formatted string
    */
    func string(number : NSNumber) -> String {
        return numberFormatter.stringFromNumber(number)!
    }
    
    /**
    Gets the formatted step count string for a step count number
    
    - parameter number: The step count number
    
    - returns: The formatted string
    */
    func stringForSteps(number : NSNumber) -> String {
        return String(format: NSLocalizedString("Shared Steps Title", comment: ""), string(number))
    }
    
    /**
    Gets the formatted distance string
    
    - parameter number: The distance in meters
    
    - returns: The formatted string
    */
    func stringForMeters(number : Double) -> String {
        return lengthFormatter.stringFromMeters(number)
    }
    
    /**
    Gets the formatted percent string for a number
    
    - parameter number: The number
    
    - returns: The formatted percent string
    */
    func percentString(number : NSNumber) -> String {
        return percentFormatter.stringFromNumber(number)!
    }
}