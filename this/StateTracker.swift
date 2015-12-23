//
//  StateTracker.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

class StateTracker: NSObject {
    
    static var defaults = NSUserDefaults.standardUserDefaults()
    
    class func save() {
        self.defaults.synchronize()
    }
    
    static var appVersion: String! {
        get {
            return self.defaults.valueForKey("VersionNumber") as? String
        }
        
        set (val) {
            self.defaults.setValue(val, forKey: "VersionNumber")
            self.save()
        }
    }

}
