//
//  StateTracker.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import Foundation

class StateTracker: NSObject {
    
    static var defaults = NSUserDefaults.standardUserDefaults()
    
    static var appVersion: String! {
        get {
            return self.defaults.valueForKey("VersionNumber") as? String
        }
        
        set (val) {
            self.defaults.setValue(val, forKey: "VersionNumber")
            self.save()
        }
    }
    
    static var tagNotifications: [String: Int] {
        get {
            guard let notifications = self.defaults.valueForKey("tagNotifications") as? [String: Int] else {
                return [:]
            }
        
            return notifications
        }
        
        set (val) {
            self.defaults.setValue(val, forKey: "tagNotifications")
            self.save()
            Globals.followingController?.reloadTags()
        }
    }
    
    static var tagPhotosUpload: [String: Int] {
        get {
            guard let notifications = self.defaults.valueForKey("tagPhotosUpload") as? [String: Int] else {
                return [:]
            }
        
            return notifications
        }
        
        set (val) {
            self.defaults.setValue(val, forKey: "tagPhotosUpload")
            self.save()
        }
    }
    
    static var tagTapDownloadShown: Bool {
        get {
            guard let shown = self.defaults.valueForKey("tagTapDownloadShown") as? Bool else {
                return false
            }
            
            return shown
        }
        
        set (val) {
            self.defaults.setValue(val, forKey: "tagTapDownloadShown")
            self.save()
        }
    }
    
    // Class Methods
    class func save() {
        self.defaults.synchronize()
    }
    
    class func setTagNotification(tag: Tag) {
        guard let id = tag.objectId else {
            return
        }
        
        var count = self.tagNotifications[id]
        
        if count == nil {
            count = 0
        }
        
        self.tagNotifications[id] = ++count!
    }
    
    class func clearTagNotification(tag: Tag) {
        guard let id = tag.objectId else {
            return
        }
        
        self.tagNotifications[id] = 0
    }
    
    class func countTagNotification(tag: Tag) -> Int {
        guard let id = tag.objectId else {
            return 0
        }
        
        guard let count = self.tagNotifications[id] else {
            return 0
        }
        
        return count
    }
    
    class func setTagPhotos(tag: Tag, increment: Int) {
        guard let id = tag.objectId else {
            return
        }
        
        var count = self.tagPhotosUpload[id]
        
        if count == nil {
            count = 0
        }
        
        self.tagPhotosUpload[id] = max(0, count! + increment)
    }
    
    class func countTagPhotos(tag: Tag) -> Int {
        guard let id = tag.objectId else {
            return 0
        }
        
        guard let count = self.tagPhotosUpload[id] else {
            return 0
        }
        
        return count
    }

}
