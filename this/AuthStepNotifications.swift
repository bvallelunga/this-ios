//
//  AuthStepNotifications.swift
//  this
//
//  Created by Brian Vallelunga on 12/29/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class AuthStepNotifications: AuthStep {
    
    override init() {
        super.init()
        
        self.title = "NOTIFICATION PERMISSIONS"
        self.nextText = "SKIP"
        self.bigText = "SURE"
        self.showBack = false
        self.background = Colors.orange
        self.input = false
        self.percent = 1
    }
    
    override func header() -> String {
        return "Can I notify you\nwhen stuff happens?"
    }
    
    override func viewed() {
        Globals.mixpanel.track("Mobile.Auth.Permissions.Notifications")
    }
    
    override func next(callback: (segue: Bool, skip: Bool) -> Void) {
        callback(segue: true, skip: false)
        Globals.mixpanel.track("Mobile.Auth.Permissions.Notifications.Skipped")
    }
    
    override func button(callback: (segue: Bool, skip: Bool) -> Void) {
        self.parentController.notifications.register()
        Globals.mixpanel.track("Mobile.Auth.Permissions.Notifications.Granted")
        
        Globals.delay(1) { () -> () in
            callback(segue: false, skip: false)
        }
    }
    
}
