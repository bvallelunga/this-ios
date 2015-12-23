//
//  Comment.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Comment: PFObject {
    
    // Instance Variables
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var message: String
    
    // Parse Setup
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Comment"
    }

}
