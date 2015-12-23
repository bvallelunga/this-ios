//
//  Photo.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Photo: PFObject {
    
    // Instance Variables
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var thumbnail: PFFile
    @NSManaged var original: PFFile
    @NSManaged var expireAt: NSDate
    
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
        return "Photo"
    }

}
