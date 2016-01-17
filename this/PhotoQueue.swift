//
//  PhotoQueue.swift
//  this
//
//  Created by Brian Vallelunga on 12/30/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse
import KTBTaskQueue

class PhotoQueue: NSObject, KTBTaskQueueDelegate  {
    
    static var queue: KTBTaskQueue!
    private static var queueDelegate: PhotoQueue!
    
    // Class Method
    class func startup() {
        guard PhotoQueue.queue == nil else {
            return
        }
        
        self.queueDelegate = PhotoQueue()
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).last!
        let queue = KTBTaskQueue(atPath: "\(cachePath)/photoQueue.db", delegate: self.queueDelegate)
        
        queue.prohibitsBackoff = false
        queue.backoffPollingInterval = 30
        
        PhotoQueue.queue = queue
    }
    
    // Instance Method
    func taskQueue(queue: KTBTaskQueue!, executeTask task: KTBTask!, completion: KTBTaskCompletionBlock!) {
        let photo = Photo(withoutDataWithObjectId: task.userInfo["photo"] as? String)
        let tag = Tag(withoutDataWithObjectId: task.userInfo["tag"] as? String)
        
        let data = NSData(base64EncodedString: task.userInfo["image"] as! String, options: .IgnoreUnknownCharacters)!
        let image = UIImage(data: data)
        let file = PFFile(name: "image.jpeg", data: data)!

        photo.original = file
        photo.thumbnail = file
        photo.tag = tag
        
        photo.saveInBackgroundWithBlock({ (success, error) -> Void in
            guard success else {
                completion(KTBTaskStatus.Failure)
                return
            }
            
            if StateTracker.countTagNotification(tag) == 1 {
                self.sendTagPush(tag, user: User.current())
            }
            
            StateTracker.setTagPhotos(tag, increment: -1)
            Globals.imageDownloader.setImage(image, forURL: NSURL(string: file.url!))
            completion(KTBTaskStatus.Success)
        })
    }
    
    func sendTagPush(tag: Tag, user: User) {
        let query = Installation.query()
        
        query?.whereKey("user", matchesQuery: tag.followers.query())
        query?.whereKey("user", notEqualTo: user)
        
        tag.fetchInBackgroundWithBlock { (_, error) -> Void in
            guard error == nil else {
                ErrorHandler.handleParse(error)
                return
            }
            
            Notifications.sendPush(query!, data: [
                "badge": "Increment",
                "actions": "viewTag",
                "tagID": tag.objectId!,
                "tagName": tag.name,
                "message": "New photos in \(tag.hashtag)",
                "alert": "\(user.name) posted to \(tag.hashtag)"
            ])
        }
    }

}
