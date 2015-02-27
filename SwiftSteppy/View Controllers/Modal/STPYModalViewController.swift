//
//  STPYModalViewController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/12/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit

class STPYModalViewController: UIViewController {

    var color: UIColor?
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let color = color {
            self.navigationController?.navigationBar.barTintColor = color
            self.view.backgroundColor = color
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Interface
    
    /**
    Configures the buttons for the standard app style
    */
    func configureButtons(buttons : [UIButton]) {
        for button in buttons {
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 5
        }
    }
    
    //MARK: Menu Button
    
    /**
    Called for view controllers that need a done button
    */
    func loadMenuBarButtonItem() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "menuButtonPressed:")
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    /**
    Called when the user presses the done button
    */
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
