//
//  STPYGCHelper.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 1/11/15.
//  Copyright (c) 2015 Andrew Finke. All rights reserved.
//

import GameKit

class STPYGCHelper: NSObject {
    
    //MARK: Reporting Steps
    
    /**
    Reports the user step counts to Game Center
    
    - parameter daySteps: The user's steps today
    - parameter weekSteps: The user's steps this week
    - parameter totalSteps: The user's steps from all time
    */
    func reportSteps(daySteps : NSInteger,_ weekSteps : NSInteger,_ totalSteps : NSInteger) {
        var scores = [GKScore]()
        if daySteps > 0 {
            let score = GKScore(leaderboardIdentifier: LeaderboardIdentifier.Day.description)
            score.value = Int64(daySteps)
            scores.append(score)
        }
        if weekSteps > 0 {
            let score = GKScore(leaderboardIdentifier: LeaderboardIdentifier.Week.description)
            score.value = Int64(weekSteps)
            scores.append(score)
        }
        if totalSteps > 0 {
            let score = GKScore(leaderboardIdentifier: LeaderboardIdentifier.Total.description)
            score.value = Int64(totalSteps)
            scores.append(score)
        }
        GKScore.reportScores(scores, withCompletionHandler: nil)
    }
    
    //MARK: Loading Leaderboards
    
    /**
    Loads the Game Center leaderboard data
    
    - parameter identifier: The leaderboard identifier
    */
    func loadLeaderboardData(identifier : LeaderboardIdentifier) {
        let request = GKLeaderboard()
        request.playerScope = .Global
        request.timeScope = identifier.timeScope
        request.identifier = identifier.description
        request.range = NSRange(location: 1, length: 100)
        request.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if scores != nil {
                STPYDataHelper.saveDataForKey(scores, key: identifier.description)
            }
        }
    }
    
    //MARK: Game Center Authentication
    
    /**
    Authenticates the local user
    
    - parameter rootViewController: The view controller to present the authentication view controller from
    */
    func authenticate(rootViewController : UIViewController, completion: ((authenticated : Bool!) -> Void)!) {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
            if let viewController = viewController {
                rootViewController.presentViewController(viewController, animated: true, completion: nil)
            }
            else if localPlayer.authenticated {
                self.loadLeaderboardData(.Day)
                self.loadLeaderboardData(.Week)
                self.loadLeaderboardData(.Total)
                STPYHKManager.sharedInstance.sendGKData()
                completion(authenticated: true)
            }
            else {
                self.showGameCenterAlert(rootViewController)
                completion(authenticated: false)
            }
        }
    }
    
    /**
    An alert for when the app can't authenticate the user
    
    - parameter viewController: The view controller to present the alert view controller from
    */
    func showGameCenterAlert(viewController : UIViewController) {
        let alertController = UIAlertController(title: NSLocalizedString("Shared GC Error Title", comment: ""), message: NSLocalizedString("Shared GC Error Message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Shared GC Error Button", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

enum LeaderboardIdentifier {
    case Day
    case Week
    case Total
    
    var description : String {
        switch self {
        case .Day: return "com.atfinkeproductions.SwiftSteppy.day"
        case .Week: return "com.atfinkeproductions.SwiftSteppy.week"
        case .Total: return "com.atfinkeproductions.SwiftSteppy.total"
        }
    }
    
    var timeScope : GKLeaderboardTimeScope {
        switch self {
        case .Day: return .Today
        case .Week: return .Week
        case .Total: return .AllTime
        }
    }
}
