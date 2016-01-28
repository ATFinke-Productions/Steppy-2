//
//  STPYGraphBar.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

class STPYGraphBar: UIView {

    var steps, divider : NSInteger!
    var dateKey : String!
    var filledView : UIView!
    var maxHeight = CGFloat(0)
    var progressToSet = CGFloat(0)
    
    /**
    Sets the bar's filled view progress towards full height
    
    - parameter progress: The bar progress
    */
    func setProgress(progress : CGFloat) {
        if self.frame.height > 0 && maxHeight == CGFloat(0) {
            maxHeight = CGFloat(self.frame.height) * CGFloat(steps) / CGFloat(self.divider)
        }
        else if self.frame.height == CGFloat(0) {
            progressToSet = progress
            NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "setProgressLater:", userInfo: nil, repeats: true)
        }
        else if maxHeight == CGFloat(0) {
            return
        }
        var height = CGFloat(maxHeight)
        height = height * progress
        filledView.frame = CGRectMake(filledView.frame.origin.x, self.frame.height-height, filledView.frame.width, height)
    }
    
    /**
    Sets the bar's filled view progress towards full height while making sure the frame is laid out
    
    - parameter timer: The timer checking if view laid out
    */
    func setProgressLater(timer : NSTimer) {
        if self.frame.height > 0 {
            timer.invalidate()
            setProgress(progressToSet)
        }
    }
    
    /**
    Creates the inner view of the bar that the user sees
    */
    func createInnerView() {
        filledView = UIView(frame: CGRectZero)
        filledView.backgroundColor = UIColor.whiteColor()
        filledView.layer.cornerRadius = 4
        filledView.layer.masksToBounds = false
        filledView.layer.cornerRadius = 4
        filledView.layer.shadowOffset = CGSizeMake(0, 3)
        filledView.layer.shadowRadius = 2
        filledView.layer.shadowOpacity = 0.5
        filledView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        addSubview(filledView)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("BarTapped", object: dateKey)
    }
}
