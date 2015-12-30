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
    @NSManaged var user: User!
    @NSManaged var appBuildNumber: String
    @NSManaged var appVersionBuild: String
    
    // Instance Methods
    class func startup() {
        let installation = Installation.currentInstallation()
        
        installation.appBuildNumber = Globals.appBuild()
        installation.appVersionBuild = Globals.appVersionBuild()
        installation.badge = 0
        installation.saveInBackground()
    }
    
    class func setUser(user: User) {
        let installation = Installation.currentInstallation()
        
        guard installation.user == nil else {
            return
        }
        
        installation.user = user
        installation.saveInBackground()
    }

    class func setDeviceToken(token: NSData) {
        let installation = Installation.currentInstallation()
        
        installation.setDeviceTokenFromData(token)
        installation.saveInBackground()
        
        Globals.mixpanel.people.addPushDeviceToken(token)
    }
    
    class func clearBadge() {
        let installation = Installation.currentInstallation()
        
        installation.badge = 0
        installation.saveInBackground()
    }
}
