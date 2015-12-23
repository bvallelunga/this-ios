//
//  Installation.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Installation: PFInstallation {
    
    // Instance Variables
    @NSManaged var user: User
    @NSManaged var appBuild: String
    @NSManaged var appVersion: String
    
    // Parse Setup
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    // Instance Methods
    func startup() {
        self.appVersion = Globals.appVersion()
        self.appBuild = Globals.appBuildVersion()
        self.saveEventually()
    }

}
