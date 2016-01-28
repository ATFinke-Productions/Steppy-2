//
//  STPYLeaderboardViewController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/10/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import UIKit
import GameKit

class STPYLeaderboardViewController: STPYModalViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dayLeaderboard = STPYDataHelper.getObjectForKey(LeaderboardIdentifier.Day.description) as! [GKScore]?
    let weekLeaderboard = STPYDataHelper.getObjectForKey(LeaderboardIdentifier.Week.description) as! [GKScore]?
    let totalLeaderboard = STPYDataHelper.getObjectForKey(LeaderboardIdentifier.Total.description) as! [GKScore]?
    
    var currentLeaderboard : [GKScore]!
    
    //MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var navigationBarView: STPYNavigationBarView!
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navBar = self.navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            navBar.shadowImage = UIImage()
        }
        
        if let font = UIFont(name: "AvenirNext-Medium", size: 14) {
            segmentedControl.setTitleTextAttributes([NSFontAttributeName : font], forState: .Normal)
        }
        segmentedControl.setTitle(NSLocalizedString("Leaderboards Today Text", comment: ""), forSegmentAtIndex: 0)
        segmentedControl.setTitle(NSLocalizedString("Leaderboards Week Text", comment: ""), forSegmentAtIndex: 1)
        segmentedControl.setTitle(NSLocalizedString("Leaderboards Total Text", comment: ""), forSegmentAtIndex: 2)
        self.navigationItem.title = NSLocalizedString("Leaderboards Title", comment: "")
        
        navigationBarView.backgroundColor = color
        
        currentLeaderboard = dayLeaderboard
        
        loadMenuBarButtonItem()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    /**
    Called when the user changes the selected leaderboard
    */
    @IBAction func segmentChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            currentLeaderboard = dayLeaderboard
        case 1:
            currentLeaderboard = weekLeaderboard
        default:
            currentLeaderboard = totalLeaderboard
        }
        self.tableView.reloadData()
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
    }

    //MARK: Table View
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        let score = currentLeaderboard[indexPath.row]
        cell.textLabel?.text = score.player.alias
        cell.detailTextLabel?.text = STPYFormatter.sharedInstance.stringForSteps(Int(score.value) as NSNumber)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentLeaderboard = currentLeaderboard {
            return currentLeaderboard.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
