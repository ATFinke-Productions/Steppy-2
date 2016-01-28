//
//  STPYDateHelper.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

class STPYDateHelper: NSObject {
    
    /**
    Gets the day abbreviations for the week
    
    - returns: The array of abbreviations
    */
    class func dayAbbreviations() -> [String] {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let comps = NSDateComponents()
        comps.day = 21
        comps.month = 12
        comps.year = 2014
        var date = calendar.dateFromComponents(comps)
        var strings = [String]()
        for var day = 0; day < 7; day++ {
            strings.append(STPYFormatter.sharedInstance.string(date!, format: "eee"))
            date = date?.nextDay()
        }
        return strings
    }
}

extension NSDate {
    
    /**
    Gets the next days date
    
    - returns: The date
    */
    func nextDay() -> NSDate {
        return dateByAddingTimeInterval(86400)
    }
    
    /**
    Gets the last date of the previous day
    
    - returns: The date
    */
    func endOfPreviousDay() -> NSDate {
        return dateByAddingTimeInterval(-1)
    }
    
    /**
    Gets the date for the beginning of the day
    
    - returns: The date
    */
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let dateComps = calendar.components([.Year, .Month, .Day], fromDate: self)
        dateComps.hour = 0
        dateComps.minute = 0
        dateComps.second = 0
        return calendar.dateFromComponents(dateComps)!
    }
    
    /**
    Gets the date for the beginning of the week
    
    - returns: The date
    */
    func beginningOfWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        var date : NSDate?
        var interval : NSTimeInterval = 0
        calendar.rangeOfUnit(.WeekOfYear, startDate: &date, interval: &interval, forDate: self)
        if let date = date {
            return date.beginningOfDay()
        }
        return NSDate()
    }
    
    /**
    Gets the key for the beginning of the week
    
    - returns: The key
    */
    func beginningOfWeekKey() -> String {
        return beginningOfWeek().key()
    }
    
    /**
    Gets a Steppy date key for the date
    
    - returns: The key
    */
    func key() -> String {
        return STPYFormatter.sharedInstance.string(self, format: "yyyy-MM-dd")
    }
    
    /**
    Creates new NSDate instance from the Steppy date key
    
    - parameter key: The Steppy date key
    */
    convenience init(key : String) {
        self.init(timeInterval:0, sinceDate:STPYFormatter.sharedInstance.date(key, format: "yyyy-MM-dd"))
    }
}