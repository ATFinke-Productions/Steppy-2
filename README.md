
An open-source remake of my step tracking app, Steppy. Now written entirely in Swift and integrated with the Health app in iOS 8. [Download it for free!](https://itunes.apple.com/us/app/steppy-2/id957204397?ls=1&mt=8)

##Table Of Contents

1. [Compatibility](https://github.com/ATFinke-Productions/Steppy-2#compatibility)
2. [Class Overview](https://github.com/ATFinke-Productions/Steppy-2#class-overview)
3. [Common Questions](https://github.com/ATFinke-Productions/Steppy-2#common-questions)
4. [Thanks](https://github.com/ATFinke-Productions/Steppy-2#thanks-to)

##Compatibility

Built with Xcode 6.1.1. Requires iOS 8.0+ for HealthKit.

## Class Overview

### General

##### STPYAppDelegate

The application delegate. Loads the UIAppearence attributes, starts GameKit authentication in STPYGCHelper, and gets called for background refreshes.

##### STPYColor

Extension of UIColor. Includes the application background colors and also helps in creating colors for smooth transition between other colors.

##### STPYNavigationBarView

The view that appears to extend the navigation bar. Used in STPYLeaderboardViewController

##### STPYSummaryView

The view that appears in the top scroll view in STPYGraphViewController.

##### STPYGraphView

The view that contains and manages a single graph.

##### STPYGraphBar

Each bar in a STPYGraphView. Has another UIView inside of it that appears to grow/shrink in the eyes of the user, but actually stays constant to easily detect touches.

### Helpers

##### STPYGCHelper

Handles Game Center authentication, leaderboard data downloading, and submitting step counts.

##### STPYHKManager

The link between HealthKit and the app. Queries data and saves it for display.

##### STPYDataHelper

Link to NSUserDefaults for classes to easily save and load data.

##### STPYDateHelper

Contains NSDate extensions that help with storing data. Also gets localized day abbreviations for the graphs.

##### STPYFormatter

Class to reuse various NSFormatters that are used throughout the app.

##### STPYCMHelper

Gets the lastest step data from the Core Motion framework instead of HealthKit.

### View Controllers

##### STPYGraphViewController

The main view controller of the app. Displays the step data in the form of interactive graphs in a scroll view.

##### STPYModalViewController

The view controller all other modal view controllers in the app inherit from. Allows for consitent button style setting and easily adding menu/dismiss/done button to controllers. Also helps in making sure background color is the same as the STPYGraphViewController.

##### STPYAboutViewController

The view controller that displays basic infomation about the app (name/version/build). Also allows the user to toggle Game Center features.

##### STPYLeaderboardViewController

The view controller that displays the step count leaderboards. Only enabled if the user is signed into Game Center. Uses a UISegmenetedControl to allow the user to select leaderboard time span.

##### STPYSetupViewController

The view controller that displays on first launch of the app. Allows the user to sign into Game Center and authenticate app with HealthKit.

##### STPYGraphExtensionViewController

The view controller for the graph extension in Notification Center.

##### STPYStepTableViewController

The view controller for the step count extension in Notification Center.

## Common Questions

### Hey Andrew, why is it free?
At this point in my life, seeing a high download count is more rewarding than a few extra dollars.

### But why not have ads?
I spent a lot of time crafting a simple, elegant user interface. I'm not going to ruin it by sticking an ad in the middle of it.

## Thanks To

### My Beta Testers
Thanks to William Preston, Sam Lim, Stephen Stearns, and Varun Gupta for being awesome beta testers. Especially Sam. Sam was pretty awesome. If you want to beta test any of my [future projects](http://i.imgur.com/JBVwMIP.png) send me an email from my [website](http://www.atfinkeproductions.com).

### Apple
Thanks to Apple for allowing me attend WWDC 2012-14 on [student scholarship](https://developer.apple.com/wwdc/students/). It's my Disneyland.

