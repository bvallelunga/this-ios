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
        self.header = "Can I notify you\nwhen stuff happens?"
        self.bigText = "SURE"
        self.showBack = false
        self.background = Colors.orange
        self.input = false
        self.percent = 1
    }
    
    override func next(callback: (segue: Bool, skip: Bool) -> Void) {
        callback(segue: true, skip: false)
    }
    
    override func button(callback: (segue: Bool, skip: Bool) -> Void) {
        self.parentController.notifications.register()
        
        Globals.delay(1) { () -> () in
            callback(segue: false, skip: false)
        }
    }
    
}
