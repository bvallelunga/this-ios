//
//  Notifications.swift
//  this
//
//  Created by Brian Vallelunga on 12/29/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import Parse
import Mixpanel

class Notifications: NSObject {
    
    var enabled = false
    var application = UIApplication.sharedApplication()
    
    override init() {
        if self.application.respondsToSelector(Selector("currentUserNotificationSettings")) {
            let settings = self.application.currentUserNotificationSettings()!
            self.enabled = settings.types.contains(.Alert)
        }  else {
            self.enabled = self.application.enabledRemoteNotificationTypes() != .None
        }
    }
    
    // Class Methods
    class func handle(application: UIApplication, info: [NSObject : AnyObject]) {
        var actions: [String]!
        var wasActive = true
        
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(info, block: nil)
            Mixpanel.sharedInstance().trackPushNotification(info)
            wasActive = false
        }
        
        if let tempActions = info["actions"] as? String {
            actions = tempActions.componentsSeparatedByString(",")
        } else if let tempAction = info["action"] as? String {
            actions = [tempAction]
        }
        
        if actions != nil && !actions.isEmpty {
            for (var action) in actions {
                action = action.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                switch(action) {
                    case "viewTag": self.handeViewTag(wasActive, info: info)
                    
                    default: print(action)
                }
            }
        }
        
        Installation.clearBadge()
    }
    
    class func handeViewTag(wasActive: Bool, info: [NSObject : AnyObject]) {
        let tag = Tag(withoutDataWithObjectId: info["tagID"] as? String)
        
        StateTracker.setTagNotification(tag)
        
        if wasActive {
            guard let message = info["message"] as? String else {
                Globals.commentsTag(tag)
                return
            }
            
            NavNotification.show(message, color: Colors.purple, callback: { () -> Void in
                Globals.viewTag(tag)
            })
        } else {
            Globals.viewTag(tag, animated: false)
        }
    }
    
    class func sendPush(query: PFQuery, let data: [NSObject : AnyObject]) -> BFTask {
        let push = PFPush()
        
        push.setQuery(query)
        push.setData(data)
    
        return push.sendPushInBackground()
    }
    
    // Instance Methods
    func register() {
        if self.application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            self.application.registerUserNotificationSettings(settings)
            self.application.registerForRemoteNotifications()
        } else {
            self.application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
    }
    
}