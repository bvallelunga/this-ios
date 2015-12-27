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
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var thumbnail: PFFile
    @NSManaged var original: PFFile
    @NSManaged var expireAt: NSDate
    
    var originalCached: UIImage!
    
    static func parseClassName() -> String {
        return "Photo"
    }
    
    // Class Methods
    class func create(user: User, image: UIImage, tag: Tag, expireAt: NSDate, callback: (photo: Photo) -> Void) {
        let photo = Photo()
        
        photo.user = user
        photo.tag = tag
        photo.expireAt = expireAt
        photo.originalCached = image
        
        photo.saveInBackgroundWithBlock { (success, error) -> Void in
            guard success else {
                ErrorHandler.handleParse(error)
                return
            }
            
            callback(photo: photo)
            
            let data = UIImageJPEGRepresentation(image, 0.7)
            let file = PFFile(name: "image.jpeg", data: data!)!
            
            photo.original = file
            photo.thumbnail = file
            photo.saveInBackgroundWithBlock({ (success, error) -> Void in
                guard success else {
                    ErrorHandler.handleParse(error)
                    return
                }

                Globals.imageStorage.setImage(image, forKey: file.url, diskOnly: false)
            })
        }
    }

    // Instance Method
    func fetchThumbnail(callback: (image: UIImage) -> Void) {
        guard let url = self.thumbnail.url else {
            if let image = self.originalCached {
                callback(image: image)
            }
            
            return
        }
        
        Globals.fetchImage(url, callback: callback)
    }
    
    func fetchOriginal(callback: (image: UIImage) -> Void) {
        guard let url = self.original.url else {
            if let image = self.originalCached {
                callback(image: image)
            }
            
            return
        }
        
        Globals.fetchImage(url, callback: callback)
    }
}
