//
//  Comment.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Comment: PFObject, PFSubclassing {
    
    // Instance Variables
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var message: String
    @NSManaged var from: String
    @NSManaged var flagged: Bool
    
    static func parseClassName() -> String {
        return "Comment"
    }
    
    // Class Methods
    class func create(message: String, tag: Tag, user: User) -> Comment {
        let comment = Comment()
        
        comment.message = message
        comment.tag = tag
        comment.user = user
        comment.flagged = false
        comment.from = user.screenname
        
        comment.saveInBackground().continueWithSuccessBlock { (task) -> AnyObject? in
            tag.comments.addObject(comment)
            
            return tag.saveInBackground()
        }.continueWithSuccessBlock { (task) -> AnyObject? in
            let query = Installation.query()
            
            query?.whereKey("user", matchesQuery: tag.followers.query())
            query?.whereKey("user", notEqualTo: user)
            
            return Notifications.sendPush(query!, data: [
                "badge": "Increment",
                "actions": "viewTag",
                "tagID": tag.objectId!,
                "tagName": tag.name,
                "alert": "\(user.name): \(message)"
            ])
        }.continueWithBlock { (task) -> AnyObject? in
            ErrorHandler.handleParse(task.error)
            return nil
        }
        
        return comment
    }
    
    // Instance Methods
    func flag() {
        self.flagged = true
        self.saveInBackground()
    }

}
