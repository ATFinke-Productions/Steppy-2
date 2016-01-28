//
//  STPYHKManager.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/10/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit
import HealthKit

protocol STPYHKManagerProtocol {
    func loadingProgressUpdated(progress : String)
}

class STPYHKManager: NSObject {
    
    class var sharedInstance : STPYHKManager {
        struct Static {
            static let instance : STPYHKManager = STPYHKManager()
        }
        return Static.instance
    }

    let gkHelper = STPYGCHelper()
    let cmHelper = STPYCMHelper()
    
    let hkStore : HKHealthStore = HKHealthStore()
    let stepSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    let distanceSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    
    var stepCountData = [String:[String:Int]]()
    var distanceData = [String:Double]()
    var distanceDayData = [String:Double]()
    
    var totalSteps = 0
    var weeksOfData = 0
    var graphEqualizer = 1
    
    var totalQueries = 0
    var completedQueries = 0
    
    var lastDate : NSDate?
    
    var delegate : STPYHKManagerProtocol?
    var dataFinalized : (((NSError!) -> Void)!)
    
    
    //MARK: HealthKit Access
    
    /**
    Detects if the app had access to necessary HealthKit data
    */
    func hasAccess(completion: ((access : Bool) -> Void)!) {
        lastDateQuery(true) { (lastDate) -> Void in
            if let _ = lastDate {
                self.lastDateQuery(false) { (date) -> Void in
                    if let date = date {
                        self.cmHelper.pedometerDataForToday({ (steps, distance, date) -> Void in
                            //To get inital access
                        })
                        completion(access: true)
                    }
                    else {
                        completion(access: false)
                    }
                    self.completedQueries++
                }
            }
            else {
                completion(access: false)
            }
        }
    }
    
    /**
    Shows an alert for having no HealthKit data
    
    - parameter viewController: The view controller to present the alert view controller from
    */
    func showDataAlert(viewController : UIViewController) {
        let alertController = UIAlertController(title: NSLocalizedString("No Data Title", comment: ""), message: NSLocalizedString("No Data Message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Shared GC Error Button", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Starting And Ending Data Process
    
    /**
    Queries the HealthKit data
    */
    func queryData(completion: ((NSError!) -> Void)!) {
        dataFinalized = completion
        loadData()
        completedQueries = 0
        totalQueries = 0
        lastDateQuery(true) { (date) -> Void in
            var date = date
            if let lastDate = self.lastDate {
                date = lastDate
            }
            if let date = date {
                self.buildDataStoreWithLastDataDate(date)
                self.loadDistanceDataWithLastDataDate(date)
                self.loadStepDataWithLastDataDate(date)
                self.lastDate = date
            }
            else {
                completion(NSError(domain: "com.atfinkeproductions.SwiftSteppy", code: 101, userInfo: nil))
            }
            self.completedQueries++
        }
        getTotalSteps { (steps, error) -> Void in
            if error == nil {
                self.totalSteps = Int(steps)
            }
        }
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "finalizeData:", userInfo: nil, repeats: true)
    }
    
    /**
    Finalizes the data for display and processing
    */
    func finalizeData(timer : NSTimer) {
        if !isDataReady() {
            if totalQueries < 2 {
                delegate?.loadingProgressUpdated(STPYFormatter.sharedInstance.percentString(0))
            }
            else {
                delegate?.loadingProgressUpdated(STPYFormatter.sharedInstance.percentString(Double(completedQueries) / Double(totalQueries)))
            }
            return
        }
        timer.invalidate()
        print(stepCountData)
        cmHelper.pedometerDataForToday { (steps, distance, date) -> Void in
            self.graphEqualizer = max(self.graphEqualizer, steps)
            self.adjustCurrentDataForPedometerData(steps, distance: distance, date: date)
            self.delegate?.loadingProgressUpdated(STPYFormatter.sharedInstance.percentString(1))
            self.saveData()
            self.dataFinalized(nil)
        }
    }
    
    /**
    Adjusts the HealthKit data with the lastest Pedometer data which is more up to date
    
    - parameter steps: The step count
    - parameter steps: The distance
    - parameter steps: The date
    */
    func adjustCurrentDataForPedometerData(steps : Int, distance : Double, date : NSDate) {
        if let week = stepCountData[date.beginningOfWeek().key()] {
            if let currentDay = week[date.key()] {
                if currentDay < steps {
                    totalSteps = max(totalSteps, totalSteps - currentDay + steps)
                    stepCountData[date.beginningOfWeek().key()]![date.key()] = steps
                    self.graphEqualizer = max(self.graphEqualizer, steps)
                    let oldDistance = distanceDayData[date.key()]!
                    distanceDayData[date.key()] = distance
                    let oldWeekDistance = distanceData[date.beginningOfWeek().key()]!
                    distanceData[date.beginningOfWeek().key()] = oldWeekDistance - oldDistance + distance
                }
            }
        }
    }
    
    /**
    Detects if still waiting for queries
    */
    func isDataReady() -> Bool {
        return completedQueries >= totalQueries && distanceData.count > 0
    }
    
    //MARK: Getting Distance Data
    
    /**
    Loads the distance data since the date
    
    - parameter lastDate: The last date to get data from
    */
    func loadDistanceDataWithLastDataDate(lastDate : NSDate) {
        let date = NSDate()
        var start = date.beginningOfWeek()
        var end = date
        while lastDate.timeIntervalSinceDate(start) <= 0 {
            loadDistanceData(start, end, forWeek: true)
            end = start.endOfPreviousDay()
            start = end.beginningOfWeek()
        }
    }
    
    /**
    Loads the distance data for a specifc week or day
    
    - parameter start: The start of the time period
    - parameter end: The end of the time period
    */
    func loadDistanceData(start : NSDate,_ end : NSDate, forWeek : Bool) {
        statsQuery(start, end, steps: false) { (result, error) -> Void in
            if let sumQuantity = result?.sumQuantity() {
                let key = start.key()
                let value = sumQuantity.doubleValueForUnit(HKUnit.meterUnit())
                if forWeek == true {
                    self.distanceData[key] = value
                }
                else {
                    self.distanceDayData[key] = value
                }
            }
            self.completedQueries++
        }
    }
    
    //MARK: Getting Step Counts
    
    /**
    Loads the step data since the date
    
    - parameter lastDate: The last date to get data from
    */
    func loadStepDataWithLastDataDate(lastDate : NSDate) {
        let date = NSDate()
        var start = date.beginningOfDay()
        var end = date
        while lastDate.timeIntervalSinceDate(start) < 0 {
            loadStepDataForDay(start, end)
            loadDistanceData(start, end, forWeek: false)
            end = start.endOfPreviousDay()
            start = end.beginningOfDay()
        }
    }
    
    /**
    Loads the step data for a specifc day
    
    - parameter start: The start of the day
    - parameter end: The end of the day
    */
    func loadStepDataForDay(start : NSDate,_ end : NSDate) {
        let key = start.key()
        let weekKey = start.beginningOfWeekKey()
        statsQuery(start, end, steps: true) { (result, error) -> Void in
            if let sumQuantity = result?.sumQuantity() {
                let steps = Int(sumQuantity.doubleValueForUnit(HKUnit.countUnit()))
                if self.stepCountData[weekKey] != nil {
                    self.stepCountData[weekKey]![key] = steps
                }
                self.graphEqualizer = max(self.graphEqualizer, steps)
            }
            else {
                if self.stepCountData[weekKey]![key] == nil {
                    self.stepCountData[weekKey]![key] = 0
                }
            }
            self.completedQueries++
        }
    }
    
    /**
    Counts the steps for a set of week data
    
    - parameter data: The week data
    
    - returns: The number of steps
    */
    func getWeekStepsFromData(data : [String:Int]) -> Int {
        var steps = 0
        for day in data.keys {
            steps += data[day]!
        }
        return steps
    }
    
    /**
    Gets the total number of steps
    */
    func getTotalSteps(completion: ((Double!, NSError!) -> Void)!) {
        statsQuery(NSDate.distantPast() , NSDate(), steps: true) { (result, error) -> Void in
            if let sumQuantity = result?.sumQuantity() {
                completion(sumQuantity.doubleValueForUnit(HKUnit.countUnit()),nil)
            }
            else {
                completion(0,error)
            }
            self.completedQueries++
        }
    }
    
    /**
    Generic stats query
    
    - parameter start: The start date
    - parameter end: The end date
    - parameter steps: Bool if is step query
    */
    func statsQuery(start : NSDate,_ end : NSDate, steps : Bool, completion: (result : HKStatistics!, error : NSError!) -> Void) {
        totalQueries++
        let quantityType = steps ? stepSampleType : distanceSampleType
        let query = HKStatisticsQuery(quantityType: quantityType!, quantitySamplePredicate: HKQuery.predicateForSamplesWithStartDate(start, endDate:end, options: .None), options: .CumulativeSum) { (query, result, error) -> Void in
            completion(result: result, error: error)
        }
        hkStore.executeQuery(query)
    }
    
    /**
    Generic sample query
    
    - parameter steps: Bool if is step query
    */
    func lastDateQuery(steps : Bool, completion: (date : NSDate?) -> Void) {
        totalQueries++
        let quantityType = steps ? stepSampleType : distanceSampleType
        let sampleQuery = HKSampleQuery(sampleType: quantityType!, predicate: HKQuery.predicateForSamplesWithStartDate(NSDate.distantPast() as! NSDate, endDate:NSDate(), options: .None), limit: 1, sortDescriptors: [NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)]) { (sampleQuery : HKSampleQuery, results : [HKSample]?, error : NSError?) -> Void in
            if let results = results {
                if let firstSample = results.first as? HKQuantitySample {
                    completion(date: firstSample.startDate.beginningOfWeek())
                }
                else {
                    completion(date: nil)
                }
            }
            else {
                completion(date: nil)
            }
        }
        hkStore.executeQuery(sampleQuery)
    }
    
    //MARK: Building the data store
    
    /**
    Builds the default data values and keys from a date
    
    - parameter lastDate: The last date to build the data
    */
    func buildDataStoreWithLastDataDate(lastDate : NSDate) {
        let date = NSDate()
        var start = date.beginningOfWeek()
        var end = date
        while lastDate.timeIntervalSinceDate(start) <= 0 {
            let key = start.key()
            if stepCountData[key] == nil {
                stepCountData[key] = [String:Int]()
            }
            buildDataStoreForWeekStart(start)
            
            if distanceData[key] == nil {
                distanceData[key] = 0.0
            }
            end = start.endOfPreviousDay()
            start = end.beginningOfWeek()
        }
    }
    
    /**
    Builds the default data values and keys for a specific week
    
    - parameter lastDate: The last date of the week
    */
    func buildDataStoreForWeekStart(lastDate : NSDate) {
        var date = lastDate
        for var day = 1; day < 8; day++ {
            if distanceDayData[date.key()] == nil {
                distanceDayData[date.key()] = 0.0
            }
            if stepCountData[lastDate.key()]![date.key()] == nil {
                stepCountData[lastDate.key()]![date.key()] = 0
            }
            date = date.nextDay()
        }
    }
    
    //MARK: Saving, Storing, and Moving Data
    
    /**
    Saves the latest data
    */
    func saveData() {
        weeksOfData = distanceData.count
        STPYDataHelper.saveDataForKey(graphEqualizer, key: "graphEqualizer")
        STPYDataHelper.saveDataForKey(distanceData, key: "distanceData")
        STPYDataHelper.saveDataForKey(distanceDayData, key: "distanceDayData")
        STPYDataHelper.saveDataForKey(stepCountData, key: "stepCountData")
        STPYDataHelper.saveDataForKey(NSDate(timeIntervalSinceNow: -200000), key: "lastDate")
        saveDataForExtension()
        if STPYDataHelper.key("GKEnabled") {
            self.sendGKData()
        }
    }
    
    /**
    Loads previously saved data
    */
    func loadData() {
        if let object = STPYDataHelper.getObjectForKey("lastDate") as? NSDate {
             lastDate = object.beginningOfDay()
        }
        if let object = STPYDataHelper.getObjectForKey("graphEqualizer") as? Int {
            graphEqualizer = object
        }
        if let object = STPYDataHelper.getObjectForKey("distanceData") as? [String:Double] {
            distanceData = object
        }
        if let object = STPYDataHelper.getObjectForKey("distanceDayData") as? [String:Double] {
            distanceDayData = object
        }
        if let object = STPYDataHelper.getObjectForKey("stepCountData") as? [String:[String:Int]] {
            stepCountData = object
        }
    }
    
    /**
    Saves the user's step data for the extensions
    */
    func saveDataForExtension() {
        if let defaults = NSUserDefaults(suiteName: "group.com.atfinkeproductions.SwiftSteppy") {
            let date = NSDate()
            let weekKey = date.beginningOfWeekKey()
            if let weekCountData = stepCountData[weekKey] {
                if let todaySteps = weekCountData[date.key()] {
                    defaults.setObject(todaySteps as NSNumber, forKey: "T-Steps")
                }
                defaults.setObject(getWeekStepsFromData(weekCountData) as NSNumber, forKey: "W-Steps")
                defaults.setObject(weekCountData, forKey: "W-Data")
            }
            defaults.setObject((totalSteps as NSNumber), forKey: "A-Steps")
            defaults.synchronize()
        }
    }
    
    /**
    Sends the user's step data to Game Center
    */
    func sendGKData() {
        if distanceData.count > 0 {
            let date = NSDate()
            let dayKey = date.beginningOfDay().key()
            let weekKey = date.beginningOfWeekKey()
            var daySteps = 0
            var weekSteps = 0
            if let weekData = stepCountData[weekKey] {
                if let data = weekData[dayKey] {
                    daySteps = data
                }
                weekSteps = getWeekStepsFromData(weekData)
            }
            gkHelper.reportSteps(daySteps, weekSteps, totalSteps)
        }
    }
}