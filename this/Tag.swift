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
    @NSManaged var followers: PFRelation
    @NSManaged var photos: PFRelation
    @NSManaged var comments: PFRelation
    
    static func parseClassName() -> String {
        return "Tag"
    }
    
    // Class Methods
    class func findOrCreate(name: String, callback: (tag: Tag) -> Void) {
        let query = Tag.query()
        
        query?.whereKey("name", equalTo: name)
        
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if let tag = object as? Tag {
                callback(tag: tag)
                return
            } else if error?.code != PFErrorCode.ErrorObjectNotFound.rawValue {
                ErrorHandler.handleParse(error!)
                return
            }
            
            let tag = Tag()
            
            tag.name = name
            tag.saveInBackground()
            
            callback(tag: tag)
        })
    }
    
    // Instance Methods
    func postImages(timer: Int, user: User, photos: [Photo]) {
        let expireAt = NSCalendar.currentCalendar()
            .dateByAddingUnit(.Day, value: timer, toDate: NSDate(), options: [])!
        
        self.followers.addObject(user)
        
        for photo in photos {
            self.photos.addObject(photo)
            
            photo.tag = self
            photo.expireAt = expireAt
        }
        
        Photo.saveAllInBackground(photos)
        self.saveInBackground()
    }

}
