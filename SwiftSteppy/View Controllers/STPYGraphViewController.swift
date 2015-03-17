//
//  STPYGraphViewController.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/25/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit
import GameKit

class STPYGraphViewController: UIViewController, UIScrollViewDelegate, STPYHKManagerProtocol {
    
    let titleLabel = UILabel(frame: CGRectMake(0, 0, 100, 40))
    
    var lastPageXOffset = CGFloat(0)
    var lastPage = 0
    
    var graphViews = [STPYGraphView]()
    var summaryViews = [STPYSummaryView]()
    var backgroundColors = UIColor.backgroundColors()
    
    var timerForReturnToNormal : NSTimer?
    var lastSummeryView : STPYSummaryView?
    
    //MARK: Outlets
    
    @IBOutlet weak var mainScrollView, topScrollView: UIScrollView!
    @IBOutlet weak var bottomNavigationBar: UINavigationBar!
    @IBOutlet weak var leaderboardButtonItem: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    //MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInitalInterface()
        addNotificationCenterObservers()
        STPYHKManager.sharedInstance.delegate = self
        if STPYDataHelper.key("Setup") {
            loadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !STPYDataHelper.key("Setup") {
            STPYDataHelper.keyIs(true, key: "PresentingSetup")
            showLoadingInterface()
            self.performSegueWithIdentifier("showSetup", sender: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setTopScrollViewOffset()
        configureLeaderboardButton()
    }
    
    func addNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "ReloadData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "barTapped:", name: "BarTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureLeaderboardButton", name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
    }
    
    //MARK: Loading Interface
    
    /**
    Starts the process of loading HealthKit data
    */
    func loadData() {
        showLoadingInterface()
        STPYHKManager.sharedInstance.queryData { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                if error == nil {
                    self.clean()
                    self.loadDataInterface()
                }
                else {
                    STPYHKManager.sharedInstance.showDataAlert(self)
                }
            })
        }
    }
    
    /**
    Called when the progress of loading HealthKit data is updated
    */
    func loadingProgressUpdated(progress: String) {
        dispatch_async(dispatch_get_main_queue(),{
            self.loadingLabel.text = progress
        })
    }
    
    /**
    Starts the loading the inital interface
    */
    func showInitalInterface() {
        bottomNavigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bottomNavigationBar.shadowImage = UIImage()
        bottomNavigationBar.translucent = true
        bottomNavigationBar.alpha = 0.0
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 120, 44)
        bottomNavigationBar.topItem?.titleView = titleLabel
    }
    
    /**
    Toggles the leaderboard button based on the user's Game Center authentication status
    */
    func configureLeaderboardButton() {
        leaderboardButtonItem.enabled = STPYDataHelper.key("GKEnabled") && GKLocalPlayer.localPlayer().authenticated
    }
    
    /**
    Shows the loading the interface
    */
    func showLoadingInterface() {
        if STPYDataHelper.key("PresentingSetup") {
            self.view.backgroundColor = UIColor.blackColor()
            setAlphas([activityIndicator, loadingLabel], alpha: 0.0)
        }
        else {
            backgroundColors = UIColor.backgroundColors()
            bottomNavigationBar.alpha = 0.0
            setAlphas([mainScrollView, topScrollView], alpha: 0.0)
            setAlphas([activityIndicator, loadingLabel], alpha: 1.0)
            activityIndicator.startAnimating()
            self.view.backgroundColor = backgroundColors[1]
        }
    }
    
    /**
    Starts the interface with the HealthKit data
    */
    func loadDataInterface() {
        loadMainScrollViewContent()
        loadTopScrollViewContent()
        mainScrollView.contentOffset = CGPointMake(graphViews.last!.frame.origin.x - 5, 0)
        lastPage = Int(mainScrollView.contentOffset.x / mainScrollView.frame.width)
        
        let string = NSLocalizedString("Week Total Steps Title", comment: "")
        titleLabel.text = "\(STPYFormatter.sharedInstance.string(STPYHKManager.sharedInstance.totalSteps as NSNumber)) \(string)"
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: nil, animations: {
            self.setAlphas([self.activityIndicator, self.loadingLabel], alpha: 0.0)
            }, completion: { Finished in
                if !STPYDataHelper.key("Setup") {
                    NSNotificationCenter.defaultCenter().postNotificationName("LoadedData", object: nil)
                }
                UIView.animateWithDuration(0.5, animations: {
                    self.setAlphas([self.mainScrollView, self.topScrollView,self.bottomNavigationBar], alpha: 1.0)
                    }) { (completion) -> Void in
                        self.activityIndicator.stopAnimating()
                }
        })
    }
    
    func setAlphas(views : [UIView], alpha : CGFloat) {
        for view in views {
            view.alpha = alpha
        }
    }
    
    /**
    Cleans out the views for new data
    */
    func clean() {
        for view in mainScrollView.subviews {
            view.removeFromSuperview()
        }
        for view in topScrollView.subviews {
            view.removeFromSuperview()
        }
        graphViews.removeAll(keepCapacity: false)
        summaryViews.removeAll(keepCapacity: false)
        mainScrollView.contentOffset = CGPointZero
    }

    //MARK: Loading ScrollViews
    
    /**
    Loads the main scroll view content
    */
    func loadMainScrollViewContent() {
        let weeks = STPYHKManager.sharedInstance.weeksOfData
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.width * CGFloat(weeks), 0)
        
        let dayLabels = STPYDateHelper.dayAbbreviations()
        let divider = STPYHKManager.sharedInstance.graphEqualizer
        
        for var week = 0; week < weeks; week++ {
            let graphView = STPYGraphView(frame: CGRectMake(mainScrollView.frame.width * CGFloat(week) + 5, 0, mainScrollView.frame.width - 10, mainScrollView.frame.height))
            let key = Array(STPYHKManager.sharedInstance.stepCountData.keys).sorted(<)[week] as String
            let value = STPYHKManager.sharedInstance.stepCountData[key]
            graphView.weekData = value!
            graphView.dayLabels = dayLabels
            graphView.divider = divider
            graphView.loadWithProgress(1.0)
            mainScrollView.addSubview(graphView)
            graphViews.append(graphView)
        }
    }
    
    /**
    Loads the top scroll view content
    */
    func loadTopScrollViewContent() {
        // The 1.4 number is to create the effect that the labels are moving faster than the graphs
        topScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width * 1.4, 0);
        for var week = 0; week < STPYHKManager.sharedInstance.weeksOfData; week++ {
            let summaryView = STPYSummaryView(frame: CGRectMake(mainScrollView.frame.width * CGFloat(week) * 1.4, 0, mainScrollView.frame.width, topScrollView.frame.height))
            topScrollView.addSubview(summaryView)
            let graphView = graphViews[week]
            let steps = STPYHKManager.sharedInstance.getWeekStepsFromData(graphView.weekData)
            let keys = Array(graphView.weekData.keys).sorted(<)
            let startDate = NSDate(key: keys[0])
            let endDate = NSDate(key: keys[keys.count - 1])
            summaryView.dateString = STPYFormatter.sharedInstance.string(startDate, endDate: endDate)
            summaryView.stepsString = STPYFormatter.sharedInstance.stringForSteps(steps as NSNumber)
            let key = Array(STPYHKManager.sharedInstance.distanceData.keys).sorted(<)[week]
            summaryView.distanceString = STPYFormatter.sharedInstance.lengthFormatter.stringFromMeters(STPYHKManager.sharedInstance.distanceData[key]!)
            summaryView.loadLabels()
            summaryViews.append(summaryView)
        }
    }
    
    //MARK: Main ScrollView Scrolling
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        let offset = scrollView.contentOffset.x
        
        // Gets the progress towards the next graph view
        var progress = (offset % scrollView.frame.width) / scrollView.frame.width
        if progress < 0.0 {
            progress = 1 + progress
        }
        
        var nextPageIndex = -1
        var lastPageIndex = -1
        
        // If scrolling right...
        if offset > lastPageXOffset {
            //Sets the next page index to be the current page offset plus one
            nextPageIndex = Int(offset / scrollView.frame.width) + 1
            lastPageIndex = nextPageIndex - 1
            if offset < 0 {
                // In case there are no more graph views in the scroll view
                nextPageIndex = 0
                lastPageIndex = -1
            }
        }
        else {
            //Sets the next page index to be the current page offset
            nextPageIndex = Int(offset / scrollView.frame.width)
            lastPageIndex = nextPageIndex + 1
            if offset < 0 {
                nextPageIndex = -1
                lastPageIndex = 0
            }
            progress = 1 - progress
        }
        
        setGraphProgress(nextPageIndex, lastPageIndex, progress: progress)
        setBackgroundColor(nextPageIndex, lastPageIndex, progress: progress)
        setTopScrollViewOffset()
        
        lastPageXOffset = offset
    }
    
    /**
    Scrolls the top scroll view ahead of the main scroll view
    */
    func setTopScrollViewOffset() {
        var point = mainScrollView.contentOffset
        point.x *= 1.4
        topScrollView.contentOffset = point
        // The 1.4 number is to create the effect that the labels are moving faster than the graphs
    }
    
    /**
    Adjusts the visable graph views
    */
    func setGraphProgress(next : Int,_ last : Int, progress : CGFloat) {
        if next < graphViews.count && next >= 0 {
            graphViews[next].setProgress(progress)
        }
        if last < graphViews.count && last >= 0{
            graphViews[last].setProgress(1.0 - progress)
        }
    }
    
    /**
    Sets the new background color
    */
    func setBackgroundColor(next : Int,_ last : Int, progress : CGFloat) {
        var next = next
        var last = last
        let count = backgroundColors.count
        let weeks = STPYHKManager.sharedInstance.weeksOfData
        next = weeks - next
        last = weeks - last
        if next < 0 {
            next = count - 1
        }
        if last < 0 {
            last = count - 1
        }
        let nextColor = backgroundColors[next % count]
        let currentColor = backgroundColors[last % count]
        self.view.backgroundColor = UIColor(currentColor, nextColor, mix: progress)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        lastPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    //MARK: Graph Interaction
    
    /**
    Called when a graph bar is tapped
    */
    func barTapped(notification : NSNotification) {
        lastSummeryView?.switchMode()
        timerForReturnToNormal?.invalidate()
        
        let key = notification.object as String
        let date = NSDate(key: key)
        let weekKey = date.beginningOfWeekKey()
        
        lastSummeryView = summaryViews[lastPage]
        lastSummeryView?.altDateString = STPYFormatter.sharedInstance.string(date, format: "MMMM d")
        lastSummeryView?.altDistanceString = STPYFormatter.sharedInstance.stringForMeters(STPYHKManager.sharedInstance.distanceDayData[key]!)
        lastSummeryView?.altStepsString = STPYFormatter.sharedInstance.stringForSteps(STPYHKManager.sharedInstance.stepCountData[weekKey]![key]!)
        lastSummeryView?.switchMode()
        
        timerForReturnToNormal = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "switchSummaryViewMode", userInfo: nil, repeats: false)
    }
    
    /**
    Switches the summary view after timeout
    */
    func switchSummaryViewMode() {
        lastSummeryView?.switchMode()
        lastSummeryView = nil
    }
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "showSetup" {
            let controller = (segue.destinationViewController as UINavigationController).topViewController as STPYModalViewController
            controller.color = self.view.backgroundColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}