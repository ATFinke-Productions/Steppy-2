//
//  STPYGraphExtensionViewController.swift
//  Graph
//
//  Created by Andrew Finke on 12/24/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit
import NotificationCenter

class STPYGraphExtensionViewController: UIViewController, NCWidgetProviding {
    
    let cmHelper = STPYCMHelper()
    
    //MARK: Outlets
    
    @IBOutlet weak var disclaimerLabel, dateLabel, stepsLabel: UILabel!
    @IBOutlet weak var graphView: STPYGraphView!
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(0, 200)
        
        graphView.backgroundColor = UIColor.clearColor()
        graphView.dayLabels = STPYDateHelper.dayAbbreviations()
        
        let defaults = NSUserDefaults(suiteName: "group.com.atfinkeproductions.SwiftSteppy")
        if var weekData = defaults?.objectForKey("W-Data") as [String:Int]? {
            setViews([stepsLabel,dateLabel,graphView], hidden: false)
            disclaimerLabel.hidden = true
            
            let sortedKeys = Array(weekData.keys).sorted(<)
            dateLabel.text = STPYFormatter.sharedInstance.string(NSDate(key: sortedKeys[0]), endDate: NSDate(key: sortedKeys[sortedKeys.count - 1]))
            dateLabel.adjustsFontSizeToFitWidth = true
            
            cmHelper.pedometerDataForToday { (steps, distance, date) -> Void in
                if let currentDay = weekData[date.key()] {
                    weekData[date.key()]! = max(currentDay, steps)
                }
                self.graphView.weekData = weekData
                self.graphView.divider = self.getEqualizer(weekData)
                dispatch_async(dispatch_get_main_queue(),{
                    self.graphView.loadWithProgress(1.0)
                })
            }
            var weekSteps = getWeekStepsFromData(weekData)
            cmHelper.pedometerDataForThisWeek({ (steps, distance) -> Void in
                dispatch_async(dispatch_get_main_queue(),{
                    self.stepsLabel.text = STPYFormatter.sharedInstance.stringForSteps(max(weekSteps, steps) as NSNumber)
                })
            })
        }
        else {
            setViews([stepsLabel,dateLabel,graphView], hidden: true)
            disclaimerLabel.hidden = false
        }
    }
    
    /**
    Methods that hides or shows all views in an array
    
    :param: views The views to hide or show
    :param: hidden Bool that determines whether to show or hide views
    */
    func setViews(views : [UIView], hidden : Bool) {
        for view in views {
            view.hidden = hidden
        }
    }
    
    /**
    Counts the steps for a set of week data
    
    :param: data The week data
    
    :returns: The number of steps
    */
    func getWeekStepsFromData(data : [String:Int]) -> Int {
        var steps = 0
        for day in data.keys {
            steps += data[day]!
        }
        return steps
    }
    
    /**
    Gets the equalizer value for the week data
    
    :param: weekData The week data
    
    :returns: The equalizer
    */
    func getEqualizer(weekData : [String:Int]) -> NSInteger {
        var largestNumber = 1
        for dayKey in weekData.keys {
            largestNumber = max(largestNumber, weekData[dayKey]!)
        }
        return largestNumber
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Widget Functions
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 39, left: 47, bottom: 39, right: 47)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.extensionContext?.openURL(NSURL(string: "Steppy2://")!, completionHandler: nil)
    }
}
