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
    class func random(callback: (name: String) -> Void) {
        PFCloud.callFunctionInBackground("newTag", withParameters: nil) { (response, error) -> Void in
            if let name = response as? String {
                callback(name: name)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func findOrCreate(name: String, callback: (tag: Tag) -> Void) {
        let query = Tag.query()
        
        query?.whereKey("name", equalTo: name.lowercaseString)
        
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
        PFCloud.callFunctionInBackground("trending", withParameters: nil) { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                callback(tags: tags)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    // Instance Methods
    func invite(sender: User, users: [User]) {
        for user in users {
            self.followers.addObject(user)
        }
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            guard success else {
                ErrorHandler.handleParse(error)
                return
            }
            
            // Send Push Notification
            let query = Installation.query()
            var name = sender.fullName
            
            if name.isEmpty {
                name = sender.screenname
            }
            
            query?.whereKey("user", containedIn: users)
            
            Notifications.sendPush(query!, data: [
                "badge": "Increment",
                "tagID": self.objectId!,
                "tagName": self.name,
                "message": "\(name) invited you to \(self.hashtag)"
            ])
        }
    }
    
    func suggested(numbers: [String], callback: (users: [User]) -> Void) {
        let query = User.query()
        let tagQuery = self.followers.query()
        
        query?.whereKey("phone", containedIn: numbers)
        query?.whereKey("objectId", doesNotMatchKey: "objectId", inQuery: tagQuery)
        
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects as? [User] {
                callback(users: users)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
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
            let photo = Photo.create(user, image: image, tag: self, expireAt: expireAt, callback: { (photo) -> Void in
                self.photos.addObject(photo)
                
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
            
            self.photosCached.append(photo)
        }
    }
    
}
