//
//  STPYStepTableViewController.swift
//  StepCount
//
//  Created by Andrew Finke on 12/25/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit
import NotificationCenter

class STPYStepTableViewController: UITableViewController, NCWidgetProviding {

    let today = NSLocalizedString("Leaderboards Today Text", comment: "")
    let week = NSLocalizedString("Leaderboards Week Text", comment: "")
    let total = NSLocalizedString("Leaderboards Total Text", comment: "")
    
    var data = [String:Int]()
    
    let motionHelper = STPYCMHelper()
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSizeMake(0, 132.0)
        tableView.backgroundColor = UIColor.clearColor()
        
        let defaults = NSUserDefaults(suiteName: "group.com.atfinkeproductions.SwiftSteppy")

        let todaySteps = defaults?.integerForKey("T-Steps")
        let weekSteps = defaults?.integerForKey("W-Steps")
        let totalSteps = defaults?.integerForKey("A-Steps")
        
        data[self.today] = todaySteps
        data[self.week] = weekSteps
        data[self.total] = totalSteps
        tableView.reloadData()
        
        motionHelper.pedometerDataForToday { (steps, distance, date) -> Void in
            let maxSteps = max(steps, todaySteps!)
            self.data[self.today] = maxSteps
            self.tableView.reloadData()
        }
        
        motionHelper.pedometerDataForThisWeek { (steps, distance) -> Void in
            let maxSteps = max(steps, weekSteps!)
            self.data[self.week] = maxSteps
            self.tableView.reloadData()
        }
        
        motionHelper.pedometerDataForAllTime { (steps, distance) -> Void in
            let maxSteps = max(steps, totalSteps!)
            self.data[self.total] = maxSteps
            self.tableView.reloadData()
        }
        // Do any additional setup after loading the view from its nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = today
            cell.detailTextLabel?.text = STPYFormatter.sharedInstance.stringForSteps(data[today]! as NSNumber)
        case 1:
            cell.textLabel?.text = week
            cell.detailTextLabel?.text = STPYFormatter.sharedInstance.stringForSteps(data[week]! as NSNumber)
        default:
            cell.textLabel?.text = total
            cell.detailTextLabel?.text = STPYFormatter.sharedInstance.stringForSteps(data[total]! as NSNumber)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        extensionContext?.openURL(NSURL(string: "Steppy2://")!, completionHandler: nil)
    }
    
    //MARK: Widget Functions
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 28, bottom: 39, right: 0)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        extensionContext?.openURL(NSURL(string: "Steppy2://")!, completionHandler: nil)
        super.touchesEnded(touches as Set<NSObject>, withEvent: event)
    }
}
