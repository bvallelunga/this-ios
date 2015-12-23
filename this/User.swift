//
//  User.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

var staticUser: User!

class User: PFUser {
    
    // Instance Variables
    @NSManaged var fullName: String
    @NSManaged var phoneNumber: String
    
    
    // Parse Setup
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func current() -> User! {
        return staticUser != nil ? staticUser : User.currentUser()
    }

}
