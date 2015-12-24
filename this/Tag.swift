//
//  Tag.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Tag: PFObject, PFSubclassing {
    
    // Instance Variables
    @NSManaged var name: String
    @NSManaged var followers: [User]
    @NSManaged var photos: [Photo]
    
    static func parseClassName() -> String {
        return "Tag"
    }

}
