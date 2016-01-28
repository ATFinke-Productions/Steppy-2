//
//  STPYSummaryView.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/23/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

class STPYSummaryView: UIView {

    var showingDay = false
    
    var dateString, stepsString, distanceString : String!
    var altDateString, altStepsString, altDistanceString : String!
    
    let distanceLabel = UILabel(frame: CGRectZero)
    let stepsLabel = UILabel(frame: CGRectZero)
    let dateLabel = UILabel(frame: CGRectZero)
    
    //MARK: Loading
    
    /**
    Loads the summary view labels
    */
    func loadLabels() {
        distanceLabel.text = distanceString
        distanceLabel.font = UIFont(name: "AvenirNext-Regular", size: 19)
        stepsLabel.text = stepsString
        stepsLabel.font = UIFont(name: "AvenirNext-Medium", size: 21)
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        dateLabel.adjustsFontSizeToFitWidth = true
        configureLabels([distanceLabel,stepsLabel,dateLabel])
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dateLabel(26)]-14-[distanceLabel(24)]-16-[stepsLabel(20)]", options: [], metrics: nil, views: ["distanceLabel":distanceLabel, "stepsLabel":stepsLabel, "dateLabel":dateLabel]))
    }
    
    //MARK: Adding label attributes
    
    /**
    Adds attributes to the labels
    
    - parameter labels: The labels
    */
    func configureLabels(labels : [UILabel]) {
        for label in labels {
            addBasicAttributes(label)
            addHorizontalConstraint(label)
        }
    }
    
    /**
    Configures label appearence
    
    - parameter label: The label
    */
    func addBasicAttributes(label : UILabel) {
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
    }
    
    /**
    Configures label contraints
    
    - parameter label: The label
    */
    func addHorizontalConstraint(label : UILabel) {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: [], metrics: nil, views: ["label":label]))
    }
    
    /**
    Adds the transition animation for text change to the label
    
    - parameter label: The label
    */
    func addAnimations(labels : [UILabel]) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.25
        for label in labels {
            label.layer.addAnimation(animation, forKey: "kCATransitionFade")
        }
    }
    
    //MARK: Other
    
    /**
    Switches the summary view to specifc day or week mode
    */
    func switchMode() {
        addAnimations([distanceLabel,stepsLabel,dateLabel])
        if showingDay {
            distanceLabel.text = distanceString
            stepsLabel.text = stepsString
            dateLabel.text = dateString
        }
        else {
            distanceLabel.text = altDistanceString
            stepsLabel.text = altStepsString
            dateLabel.text = altDateString
        }
        showingDay = !showingDay
    }
}
