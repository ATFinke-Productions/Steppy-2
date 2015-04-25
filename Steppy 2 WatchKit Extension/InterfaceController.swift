//
//  InterfaceController.swift
//  Steppy 2 WatchKit Extension
//
//  Created by Andrew Finke on 2/27/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    
    let today = NSLocalizedString("Leaderboards Today Text", comment: "")
    let week = NSLocalizedString("Leaderboards Week Text", comment: "")
    let total = NSLocalizedString("Leaderboards Total Text", comment: "")
    
    var reloadTimer : NSTimer?
    let motionHelper = STPYCMHelper()
    let defaults = NSUserDefaults(suiteName: "group.com.atfinkeproductions.SwiftSteppy")
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        loadTableView()
        // Configure interface objects here.
    }
    
    func loadData() {
        
        let todaySteps = defaults?.integerForKey("T-Steps")
        let weekSteps = defaults?.integerForKey("W-Steps")
        let totalSteps = defaults?.integerForKey("A-Steps")
        println(defaults?.dictionaryRepresentation())
        motionHelper.pedometerDataForToday { (steps, distance, date) -> Void in
            let maxSteps = max(steps, todaySteps!)
            let stepString = STPYFormatter.sharedInstance.stringForSteps(NSNumber(integer: maxSteps))
            let row = self.table.rowControllerAtIndex(0) as STPYTableViewCellController
            row.stepsLabel.setText(stepString)
        }
        
        motionHelper.pedometerDataForThisWeek { (steps, distance) -> Void in
            let maxSteps = max(steps, weekSteps!)
            let stepString = STPYFormatter.sharedInstance.stringForSteps(NSNumber(integer: maxSteps))
            let row = self.table.rowControllerAtIndex(1) as STPYTableViewCellController
            row.stepsLabel.setText(stepString)
        }
        
        motionHelper.pedometerDataForAllTime { (steps, distance) -> Void in
            let maxSteps = max(steps, totalSteps!)
            let stepString = STPYFormatter.sharedInstance.stringForSteps(NSNumber(integer: maxSteps))
            let row = self.table.rowControllerAtIndex(2) as STPYTableViewCellController
            row.stepsLabel.setText(stepString)
        }
    }

    func loadTableView() {
        table.setNumberOfRows(3, withRowType: "STPYTableViewCellController")
        let items = [today, week, total]
        for (index,item) in enumerate(items)  {
            let row = table.rowControllerAtIndex(index) as STPYTableViewCellController
            row.titleLabel.setText(item)
        }
    }
    
    override func willActivate() {
        loadData()
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "loadData", userInfo: nil, repeats: true)
        super.willActivate()
    }

    override func didDeactivate() {
        reloadTimer?.invalidate()
        super.didDeactivate()
    }
}
