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
    
    static func parseClassName() -> String {
        return "Comment"
    }
    
    // Class Methods
    class func create(message: String, tag: Tag, user: User) -> Comment {
        let comment = Comment()
        
        comment.message = message
        comment.tag = tag
        comment.user = user
        comment.from = user.screenname
        comment.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                tag.comments.addObject(comment)
                tag.saveInBackground()
            } else {
                ErrorHandler.handleParse(error)
            }
        }
        
        return comment
    }

}
