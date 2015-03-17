//
//  STPYAppDelegate.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

@UIApplicationMain
class STPYAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if STPYDataHelper.key("GKEnabled") {
            if let controller = window?.rootViewController {
                STPYHKManager.sharedInstance.gkHelper.authenticate(controller, completion: { (authenticated) -> Void in
                })
            }
        }
        if let font = UIFont(name: "AvenirNext-DemiBold", size: 20) {
            UINavigationBar.appearance().titleTextAttributes =  [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
        if let font = UIFont(name: "AvenirNext-Regular", size: 16) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        }
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        var hasCompleted = false
        STPYHKManager.sharedInstance.queryData { (error) -> Void in
            if !hasCompleted {
                hasCompleted = true
                completionHandler(.NewData)
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
}

