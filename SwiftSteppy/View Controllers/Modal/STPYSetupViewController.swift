//
//  STPYSetupViewController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/11/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit
import GameKit
import HealthKit

class STPYSetupViewController: STPYModalViewController {

    var enabledHealthData = false
    
    //MARK: Outlets
    
    @IBOutlet weak var titleLabel, disclaimerLabel, gameCenterLabel, healthKitLabel: UILabel!
    @IBOutlet weak var accessButton, gameCenterButton: UIButton!
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalization()
        configureButtons([accessButton,gameCenterButton])
        if self.view.frame.height < 500 {
            self.view.viewWithTag(10)?.hidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        STPYDataHelper.keyIs(false, key: "PresentingSetup")
    }
    
    /**
    Loads the localized strings for the labels
    */
    func loadLocalization() {
        self.navigationItem.title = NSLocalizedString("Setup Device Title", comment: "")
        gameCenterButton.setTitle(NSLocalizedString("Setup GC Main Button", comment: ""), forState: UIControlState.Normal)
        accessButton.setTitle(NSLocalizedString("Grant Access Button", comment: ""), forState: UIControlState.Normal)
        gameCenterLabel.text = NSLocalizedString("Game Center Disclaimer", comment: "")
        healthKitLabel.text = NSLocalizedString("HealthKit Disclaimer", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    /**
    Called when user trys to grants access to app
    */
    @IBAction func pressedAccessButton(sender: AnyObject) {
        
        if enabledHealthData {
            STPYDataHelper.keyIs(true, key: "Setup")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        if !HKHealthStore.isHealthDataAvailable() {
            self.enableButton(self.accessButton, enabled: false)
            let alert = UIAlertController(title: NSLocalizedString("No Health App Title", comment: ""), message: NSLocalizedString("No Health App Message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: nil)
        }

        enableButton(accessButton, enabled: false)
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        UINavigationBar.appearance().titleTextAttributes =  [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        let hkTypesToRead = NSSet(array:[HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,]) as! Set<HKObjectType>
        
        STPYHKManager.sharedInstance.hkStore.requestAuthorizationToShareTypes(nil, readTypes: hkTypesToRead) { (success, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(),{
                if let font = UIFont(name: "AvenirNext-DemiBold", size: 20) {
                    UINavigationBar.appearance().titleTextAttributes =  [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
                }
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            })
            
            if success {
                STPYHKManager.sharedInstance.hasAccess({ (access) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        if access == true   {
                            self.accessButton.setTitle(NSLocalizedString("Setup Device Continue Button", comment: ""), forState: UIControlState.Normal)
                            self.enabledHealthData = true
                            NSNotificationCenter.defaultCenter().postNotificationName("ReloadData", object: nil)
                        }
                        else {
                            STPYHKManager.sharedInstance.showDataAlert(self)
                        }
                        self.enableButton(self.accessButton, enabled: true)
                    })
                })
            }
        }
    }
    
    func enableButton(button : UIButton, enabled : Bool) {
        button.enabled = enabled
        UIView.animateWithDuration(0.25, animations: {
            button.alpha = enabled == true ? 1.0 : 0.5
        })
    }
    
    /**
    Called when user presses Game Center sign in button
    */
    @IBAction func pressedSignInButton(sender: AnyObject) {
        STPYHKManager.sharedInstance.gkHelper.authenticate(self, completion: { (authenticated) -> Void in
            if authenticated == true {
                self.gameCenterButton.setTitle(NSLocalizedString("Game Center Logged In", comment: ""), forState: UIControlState.Normal)
                self.enableButton(self.gameCenterButton, enabled: false)
                STPYDataHelper.keyIs(true, key: "GKEnabled")
            }
        })
    }
}
