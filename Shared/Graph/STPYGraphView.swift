//
//  STPYGraphView.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

class STPYGraphView: UIView {

    var dayLabels : [String]!
    var divider : NSInteger!
    var labels = [UILabel]()
    var bars = [STPYGraphBar]()
    var weekData = [String:Int]()
    
    /**
    Loads the graph view with an inital bar progress
    
    :param: barProgress The inital bar progress
    */
    func loadWithProgress(barProgress : CGFloat) {
        for bar in bars {
            bar.removeFromSuperview()
        }
        for label in labels {
            label.removeFromSuperview()
        }
        loadLabels()
        loadBars()
        setProgress(barProgress)
    }
    
    /**
    Loads the graph's labels
    */
    func loadLabels() {
        let labelView = UIView(frame: CGRectZero)
        self.addSubview(labelView)
        addLabelViewContraints(labelView)
        for var day = 0; day < 7; day++ {
            let label = UILabel(frame: CGRectZero)
            label.text = dayLabels[day]
            configureLabelProperties(label)
            labelView.addSubview(label)
            labelView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view":label]))
            labels.append(label)
        }
        labelView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label1][label2(label1)][label3(label1)][label4(label1)][label5(label1)][label6(label1)][label7(label1)]|", options: nil, metrics: nil, views: ["label1":labels[0],"label2":labels[1],"label3":labels[2],"label4":labels[3],"label5":labels[4],"label6":labels[5],"label7":labels[6]]))
    }
    
    /**
    Adds the label view contraints to the view
    
    :param: labelView The label view
    */
    func addLabelViewContraints(labelView : UIView) {
        labelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":labelView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(30)]|", options: nil, metrics: nil, views: ["view":labelView]))
    }
    
    /**
    Configures a graph label's properties
    
    :param: label The label
    */
    func configureLabelProperties(label : UILabel) {
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    /**
    Loads the graph's bars
    */
    func loadBars() {
        let graphView = UIView(frame: CGRectZero)
        graphView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(graphView)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":graphView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]-(30)-|", options: nil, metrics: nil, views: ["view":graphView]))
        
        let sortedDayKeys = Array(weekData.keys).sorted(<)
        
        for key in sortedDayKeys {
            
            let bar = STPYGraphBar(frame: CGRectZero)
            
            bar.dateKey = key
            bar.steps = weekData[key]
            bar.divider = Int(Double(divider) * 1.1)
            bar.backgroundColor = UIColor.clearColor()
            
            graphView.addSubview(bar)
            graphView.bringSubviewToFront(bar)
            
            bar.createInnerView()
            
            addBarContraints(bar)
            graphView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar]|", options: nil, metrics: nil, views: ["bar":bar]))
            bars.append(bar)
        }
        
        if bars.count == 7 {
            graphView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar1][bar2(bar1)][bar3(bar1)][bar4(bar1)][bar5(bar1)][bar6(bar1)][bar7(bar1)]|", options: nil, metrics: nil, views: ["bar1":bars[0],"bar2":bars[1],"bar3":bars[2],"bar4":bars[3],"bar5":bars[4],"bar6":bars[5],"bar7":bars[6]]))
        }
    }
    
    /**
    Adds the standard bar contraints to a bar
    
    :param: bar The bar
    */
    func addBarContraints(bar : STPYGraphBar) {
        bar.filledView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bar.setTranslatesAutoresizingMaskIntoConstraints(false)
        bar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[bar(0)]", options: nil, metrics: nil, views: ["bar":bar.filledView]))
        bar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(10)-[bar]-(10)-|", options: nil, metrics: nil, views: ["bar":bar.filledView]))
    }
    
    /**
    Sets the graph's bars' height progress
    
    :param: progress The bar progress
    */
    func setProgress(progress : CGFloat) {
        for bar in bars {
            bar.setProgress(progress)
        }
    }
}
