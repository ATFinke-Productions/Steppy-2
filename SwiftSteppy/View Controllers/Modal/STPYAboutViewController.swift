//
//  STPYAboutViewController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/12/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit

class STPYAboutViewController: STPYModalViewController {

    //MARK: Outlets
    
    @IBOutlet weak var gameCenterButton, sourceCodeButton, websiteButton, visitWebsite: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons([gameCenterButton,sourceCodeButton,websiteButton])
        loadMenuBarButtonItem()
        loadLocalization()
        loadVersionLabel()
        // Do any additional setup after loading the view.
    }
    
    /**
    Loads the localized strings for the labels
    */
    func loadLocalization() {
        self.navigationItem.title = NSLocalizedString("About Title", comment: "")
        sourceCodeButton.setTitle(NSLocalizedString("Source Code Button", comment: ""), forState: .Normal)
        websiteButton.setTitle(NSLocalizedString("Website Button", comment: ""), forState: .Normal)
        loadGameCenterButton()
    }
    
    /**
    Loads the version label with the build infomation
    */
    func loadVersionLabel() {
        let build: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        let version: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        versionLabel.text = "\(version!) (\(build!))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Game Center
    
    /**
    Loads the Game Center button based on user preference
    */
    func loadGameCenterButton() {
        if STPYDataHelper.key("GKEnabled") {
            gameCenterButton.setTitle(NSLocalizedString("Game Center Disable", comment: "")
                , forState: UIControlState.Normal)
        }
        else {
            gameCenterButton.setTitle(NSLocalizedString("Setup GC Title", comment: "")
                , forState: UIControlState.Normal)
        }
    }
    
    /**
    Called when the user presses the Game Center button
    */
    @IBAction func toggleGameCenter(sender: AnyObject) {
        let enabled = STPYDataHelper.key("GKEnabled")
        STPYDataHelper.keyIs(!enabled, key: "GKEnabled")
        if !enabled {
            STPYHKManager.sharedInstance.gkHelper.authenticate(self, completion: { (authenticated) -> Void in
                
            })
        }
        self.loadGameCenterButton()
    }
    
    //MARK: Websites
    
    /**
    Called when the user presses the source code button
    */
    @IBAction func viewSourceCode(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://atfinke-productions.github.io/Steppy-2/?utm_source=App&utm_medium=About&utm_campaign=App")!)
    }
    
    /**
    Called when the user presses the website button
    */
    @IBAction func visitWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.atfinkeproductions.com")!)
    }
}
