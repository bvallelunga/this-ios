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
        
        let data = NSData(base64EncodedString: task.userInfo["image"] as! String, options: .IgnoreUnknownCharacters)!
        let image = UIImage(data: data)
        let file = PFFile(name: "image.jpeg", data: data)!

        photo.original = file
        photo.thumbnail = file
        
        photo.saveInBackgroundWithBlock({ (success, error) -> Void in
            guard success else {
                completion(KTBTaskStatus.Failure)
                return
            }
            
            Globals.imageStorage.setImage(image, forKey: file.url, diskOnly: false)
            completion(KTBTaskStatus.Success)
        })
    }

}
