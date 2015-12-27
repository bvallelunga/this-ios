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
    @NSManaged var followerCount: Int
    @NSManaged var photoCount: Int
    @NSManaged var commentCount: Int
    
    var arePhotosCached: Bool = false
    var photosCached: [Photo] = []
    
    var hashtag: String {
        return "#\(name)"
    }
    
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
                ErrorHandler.handleParse(error)
                return
            }
            
            let tag = Tag()
            
            tag.name = name
            tag.saveInBackground()
            
            callback(tag: tag)
        })
    }
    
    class func trending(callback: (tags: [Tag]) -> Void) {
        let query = Tag.query()
        let photoQuery = Photo.query()
        
        photoQuery?.whereKeyExists("original")
        photoQuery?.whereKey("expireAt", greaterThan: NSDate())
        
        query?.whereKey("photos", matchesQuery: photoQuery!)
        query?.addDescendingOrder("followerCount")
        query?.addDescendingOrder("updatedAt")
        query?.addDescendingOrder("photoCount")
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                callback(tags: tags)
            } else {
                ErrorHandler.handleParse(error)
            }
        })
    }
    
    // Instance Methods
    func isUserFollowing(user: User, callback: (following: Bool) -> Void) {
        let query = self.followers.query()
        
        query.whereKey("objectId", equalTo: user.objectId!)
        
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil {
                callback(following: count > 0)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func comments(callback: (comments: [Comment]) -> Void) {
        let query = self.comments.query()
        
        query.addAscendingOrder("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let comments = objects as? [Comment] {
                callback(comments: comments)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func photos(limit: Int! = nil, callback: (photos: [Photo]) -> Void) {
        if self.arePhotosCached {
            callback(photos: self.photosCached)
            return
        }
        
        if !self.photosCached.isEmpty {
            callback(photos: self.photosCached)
        }
        
        let query = self.photos.query()
        
        query.whereKeyExists("original")
        query.whereKeyExists("thumbnail")
        query.whereKey("expireAt", greaterThan: NSDate())
        
        query.addAscendingOrder("createdAt")
        
        if limit != nil {
            query.limit = limit
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let photos = objects as? [Photo] {
                if self.photosCached.count < photos.count {
                    self.photosCached = photos
                    self.arePhotosCached = limit == nil
                }
                
                callback(photos: self.photosCached)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func postImages(timer: Int, user: User, images: [UIImage], callback: () -> Void) {
        let expireAt = NSCalendar.currentCalendar()
            .dateByAddingUnit(.Day, value: timer, toDate: NSDate(), options: [])!
        
        self.followers.addObject(user)
        
        for image in images {
            Photo.create(user, image: image, tag: self, expireAt: expireAt, callback: { (photo) -> Void in
                self.photos.addObject(photo)
                self.photosCached.append(photo)
                
                if images.last == image {
                    self.saveInBackgroundWithBlock { (success, error) -> Void in
                        if success {
                            callback()
                        } else {
                            ErrorHandler.handleParse(error)
                        }
                    }
                }
            })
        }
    }
    
}
