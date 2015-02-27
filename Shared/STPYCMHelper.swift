//
//  STPYCMHelper.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 2/8/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit
import CoreMotion

class STPYCMHelper: NSObject {
    let pedometer = CMPedometer()
    
    /**
    Gets the pedometer data for today which is more recent than HealthKit data
    */
    func pedometerDataForToday(completion: ((steps : Int, distance : String, date : NSDate) -> Void)!) {
        let date = NSDate()
        self.pedometer.queryPedometerDataFromDate(date.beginningOfDay(), toDate: date) { (data : CMPedometerData!, error) -> Void in
            if error == nil {
                let steps = data.numberOfSteps.integerValue
                let distance = STPYFormatter.sharedInstance.stringForMeters(data.distance.doubleValue)
                completion(steps: steps, distance: distance, date: date)
            }
            else {
                completion(steps: 0, distance: "", date: date)
            }
            println(error)
        }
    }
    
    /**
    Gets the pedometer data for this week which is more recent than HealthKit data
    */
    func pedometerDataForThisWeek(completion: ((steps : Int, distance : String, date : NSDate) -> Void)!) {
        let date = NSDate()
        self.pedometer.queryPedometerDataFromDate(date.beginningOfWeek(), toDate: date) { (data : CMPedometerData!, error) -> Void in
            if error == nil {
                let steps = data.numberOfSteps.integerValue
                let distance = STPYFormatter.sharedInstance.stringForMeters(data.distance.doubleValue)
                completion(steps: steps, distance: distance, date: date)
            }
            else {
                completion(steps: 0, distance: "", date: date)
            }
            println(error)
        }
    }
    
    /**
    Gets all the pedometer data
    */
    func pedometerDataForAllTime(completion: ((steps : Int, distance : String, date : NSDate) -> Void)!) {
        let date = NSDate()
        self.pedometer.queryPedometerDataFromDate(NSDate.distantPast() as NSDate, toDate: date) { (data : CMPedometerData!, error) -> Void in
            if error == nil {
                let steps = data.numberOfSteps.integerValue
                let distance = STPYFormatter.sharedInstance.stringForMeters(data.distance.doubleValue)
                completion(steps: steps, distance: distance, date: date)
            }
            else {
                completion(steps: 0, distance: "", date: date)
            }
            println(error)
        }
    }
}
