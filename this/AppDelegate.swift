//
//  AppDelegate.swift
//  this
//
//  Created by Brian Vallelunga on 12/10/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse
import ParseCrashReporting
import Mixpanel
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Initialize Parse
        let credentials = Globals.parseCredentials()
        
        Tag.registerSubclass()
        Photo.registerSubclass()
        Comment.registerSubclass()
        Installation.registerSubclass()
        User.registerSubclass()
        
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        PFUser.enableRevocableSessionInBackground()
        
        Parse.setApplicationId(credentials[0], clientKey: credentials[1])
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Update Config
        Config.update(nil)
        
        // Create Installation
        Installation.startup()
        
        // Configure Settings Panel
        StateTracker.appVersion = Globals.appVersionBuild()
        
        // Startup Photo Queue
        PhotoQueue.startup()
        
        // Startup Fabric
        #if DEBUG
            Fabric.sharedSDK().debug = true
        #endif
        
        Fabric.with([Crashlytics.self])
        
        // Setup Mixpanel
        let mixpanel = Mixpanel.sharedInstanceWithToken(Globals.mixpanelToken())
        mixpanel.miniNotificationPresentationTime = 10
        mixpanel.checkForNotificationsOnActive = true
        mixpanel.checkForSurveysOnActive = true
        mixpanel.checkForVariantsOnActive = true
        mixpanel.showNotificationOnActive = true
        mixpanel.identify(mixpanel.distinctId)
        
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload = (launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] == nil)
            
            if preBackgroundPush || oldPushHandlerOnly || noPushPayload {
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
                mixpanel.track("Mobile.App.Open")
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Installation.setDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Notifications.handle(application, info: userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        Globals.imageDownloader.removeAllObjects()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Globals.landingController?.player.play()
        Globals.selectionController?.getAssests()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Installation.clearBadge()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

