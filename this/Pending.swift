//
//  Pending.swift
//  this
//
//  Created by Brian Vallelunga on 1/20/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import Parse

class Pending: PFObject, PFSubclassing {
    
    // Instance Variables
    @NSManaged var phone: String
    @NSManaged var tag: Tag
    
    static func parseClassName() -> String {
        return "Pending"
    }
    
    // Class Methods
    class func batchCreate(contacts: [Contact], tag: Tag) {
        let pendings = contacts.map { (contact) -> Pending in
            let pending = Pending()
            
            pending.phone = contact.phone.e164
            pending.tag = tag
            
            return pending
        }
        
        Pending.saveAllInBackground(pendings)
    }
    
}