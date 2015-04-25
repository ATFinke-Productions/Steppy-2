//
//  STPYGlanceController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 4/1/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import WatchKit
import Foundation

class STPYGlanceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var todayLabel: WKInterfaceLabel!
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    
    let motionHelper = STPYCMHelper()
    let defaults = NSUserDefaults(suiteName: "group.com.atfinkeproductions.SwiftSteppy")
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let todaySteps = defaults?.integerForKey("T-Steps")
        motionHelper.pedometerDataForToday { (steps, distance, date) -> Void in
            let maxSteps = max(steps, todaySteps!)
            let stepString = STPYFormatter.sharedInstance.string(NSNumber(integer: maxSteps))
            self.stepsLabel.setText(stepString)
        }
        todayLabel.setText(NSLocalizedString("Leaderboards Today Text", comment: ""))
        titleLabel.setText(NSLocalizedString("Shared Steps Watch Title", comment: ""))
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
