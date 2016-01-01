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
    var photosCached: NSMutableArray = []
    
    var hashtag: String {
        guard self.dataAvailable else {
            return ""
        }
        
        return "#\(self.name)"
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
        
        query?.whereKey("name", equalTo: name)
        
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if let tag = object as? Tag {
                callback(tag: tag); return
            } else if error?.code != PFErrorCode.ErrorObjectNotFound.rawValue {
                ErrorHandler.handleParse(error); return
            }
            
            let tag = Tag()
            
            tag.name = name
            tag.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    callback(tag: tag)
                } else {
                    ErrorHandler.handleParse(error)
                }
            })
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
    func removeCachedPhoto(photo: Photo) {
        self.photosCached.removeObjectIdenticalTo(photo)
    }
    
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
            
            query?.whereKey("user", containedIn: users)
            query?.whereKey("user", notEqualTo: sender)
            
            Notifications.sendPush(query!, data: [
                "badge": "Increment",
                "actions": "viewTag",
                "tagID": self.objectId!,
                "tagName": self.name,
                "message": "\(sender.name) invited you to \(self.hashtag)",
                "alert": "\(sender.name) invited you to \(self.hashtag)"
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
        
        query.whereKey("flagged", notEqualTo: true)
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
            callback(photos: Array(self.photosCached) as! [Photo])
            return
        }
        
        if self.photosCached.count > 0 {
            callback(photos: Array(self.photosCached) as! [Photo])
        }
        
        let query = self.photos.query()
        
        query.whereKeyExists("original")
        query.whereKeyExists("thumbnail")
        query.whereKey("flagged", notEqualTo: true)
        query.whereKey("expireAt", greaterThan: NSDate())
        
        query.addAscendingOrder("createdAt")
        
        if limit != nil {
            query.limit = limit
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let photos = objects as? [Photo] {                
                if self.photosCached.count < photos.count {
                    self.photosCached = NSMutableArray(array: photos)
                    self.arePhotosCached = limit == nil
                }

                callback(photos: Array(self.photosCached) as! [Photo])
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func postImages(timer: Int, user: User, images: [UIImage], callback: () -> Void) {
        let expireAt = NSCalendar.currentCalendar()
            .dateByAddingUnit(.Day, value: timer, toDate: NSDate(), options: [])!
        
        let photos: [Photo] = images.map { (image) -> Photo in
            let photo = Photo.create(user, image: image, tag: self, expireAt: expireAt)
            
            self.photosCached.addObject(photo)
            
            return photo
        }
        
        Photo.saveAllInBackground(photos).continueWithSuccessBlock { (task) -> AnyObject? in
            self.followers.addObject(user)
            
            for photo in photos {
                let data = UIImageJPEGRepresentation(photo.originalCached, 0.7)!
                
                self.photos.addObject(photo)
                
                PhotoQueue.queue.enqueueTaskWithName("photoUpload", userInfo: [
                    "photo": photo.objectId!,
                    "image": data.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                ])
            }

            return self.saveInBackground()
        }.continueWithSuccessBlock { (task) -> AnyObject? in
            // Callback
            callback()
            
            // Update Mixpanel
            Globals.mixpanel.people.increment("Photos", by: images.count)
            
            // Send Push Notification
            let query = Installation.query()
            
            query?.whereKey("user", matchesQuery: self.followers.query())
            query?.whereKey("user", notEqualTo: user)
            
            return Notifications.sendPush(query!, data: [
                "badge": "Increment",
                "actions": "viewTag",
                "tagID": self.objectId!,
                "tagName": self.name,
                "message": "New photos in \(self.hashtag)",
                "alert": "\(user.name) posted to \(self.hashtag)"
            ])
        }.continueWithBlock { (task) -> AnyObject? in
            ErrorHandler.handleParse(task.error)
            return nil
        }
    }
    
}
