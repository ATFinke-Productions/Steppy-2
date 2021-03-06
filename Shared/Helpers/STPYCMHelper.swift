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
    func pedometerDataForToday(completion: ((steps : Int, distance : Double, date : NSDate) -> Void)!) {
        let date = NSDate().beginningOfDay()
        dataFromStartDay(date, completion: { (steps, distance) -> Void in
            completion(steps: steps, distance: distance, date : date)
        })
    }
    
    /**
    Gets the pedometer data for this week which is more recent than HealthKit data
    */
    func pedometerDataForThisWeek(completion: ((steps : Int, distance : Double) -> Void)!) {
        dataFromStartDay(NSDate().beginningOfWeek(), completion: { (steps, distance) -> Void in
            completion(steps: steps, distance: distance)
        })
    }
    
    /**
    Gets all the pedometer data
    */
    func pedometerDataForAllTime(completion: ((steps : Int, distance : Double) -> Void)!) {
        dataFromStartDay(NSDate.distantPast() as! NSDate, completion: { (steps, distance) -> Void in
            completion(steps: steps, distance: distance)
        })
    }
    
    /**
    Gets the pedometer data from the start day
    
    :param: startDate The starting date
    */
    func dataFromStartDay(startDate: NSDate, completion: ((steps : Int, distance : Double) -> Void)!) {
        self.pedometer.queryPedometerDataFromDate(startDate, toDate: NSDate()) { (data : CMPedometerData!, error) -> Void in
            if error == nil {
                let steps = data.numberOfSteps.integerValue
                let distance = data.distance.doubleValue
                completion(steps: steps, distance: distance)
            }
            else {
                completion(steps: 0, distance: 0.0)
            }
        }
    }
}
