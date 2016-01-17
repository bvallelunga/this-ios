//
//  Photo.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Photo: PFObject, PFSubclassing {
    
    // Instance Variables
    @NSManaged var from: String
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var flagged: Bool
    @NSManaged var thumbnail: PFFile
    @NSManaged var original: PFFile
    @NSManaged var expireAt: NSDate
    
    var originalCached: UIImage!
    
    static func parseClassName() -> String {
        return "Photo"
    }
    
    // Class Methods
    class func create(user: User, image: UIImage, expireAt: NSDate) -> Photo {
        let photo = Photo()
        
        photo.user = user
        photo.from = user.name
        photo.expireAt = expireAt
        photo.originalCached = image
        photo.flagged = false
        
        return photo
    }

    // Instance Method
    func flag() {
        self.flagged = true
        self.saveInBackground()
    }
    
    func fetchThumbnail(var backoff: Int = 5, callback: (image: UIImage) -> Void) {
        guard let url = self.thumbnail.url else {
            if let image = self.originalCached {
                callback(image: image)
            } else {
                Globals.delay(Double(backoff), closure: { () -> () in
                    self.fetchInBackgroundWithBlock({ (_, _) -> Void in
                        backoff += 5
                        
                        self.fetchThumbnail(backoff, callback: callback)
                    })
                })
            }
            
            return
        }
        
        Globals.fetchImage(url, callback: callback)
    }
    
    func fetchOriginal(var backoff: Int = 5, callback: (image: UIImage) -> Void) {
        guard let url = self.original.url else {
            if let image = self.originalCached {
                callback(image: image)
            } else {
                Globals.delay(Double(backoff), closure: { () -> () in
                    self.fetchInBackgroundWithBlock({ (_, _) -> Void in
                        backoff += 5
                        
                        self.fetchThumbnail(backoff, callback: callback)
                    })
                })
            }
            
            return
        }
        
        Globals.fetchImage(url, callback: callback)
    }
}
