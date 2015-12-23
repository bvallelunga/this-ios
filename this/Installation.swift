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
    @NSManaged var appBuildNumber: String
    @NSManaged var appVersionBuild: String
    
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
    class func startup() {
        let installation = Installation.currentInstallation()
        
        installation.appBuildNumber = Globals.appBuild()
        installation.appVersionBuild = Globals.appVersionBuild()
        installation.saveEventually()
    }

}