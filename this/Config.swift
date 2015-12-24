//
//  Config.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

var updating = false

class Config {
    
    // MARK: Instance Variables
    var host: String!
    var itunesId: String!
    var uploadLimit: Int!
    var downloadUrl: String!
    var termsURL: String!
    var privacyURL: String!
    var faqsURL: String!
    var facebookMessage: String!
    var twitterMessage: String!
    var inviteMessage: String!
    var parse: PFConfig!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFConfig) {
        self.init()
        
        self.host = object["host"] as? String
        self.downloadUrl = object["downloadURL"] as? String
        self.termsURL = object["termsURL"] as? String
        self.privacyURL = object["privacyURL"] as? String
        self.faqsURL = object["faqsURL"] as? String
        self.itunesId = object["itunesId"] as? String
        self.uploadLimit = object["uploadLimit"] as? Int
        self.facebookMessage = object["facebookMessage"] as? String
        self.twitterMessage = object["twitterMessage"] as? String
        self.inviteMessage = object["inviteMessage"] as? String
        self.parse = object
    }
    
    // MARK: Class Methods
    class func sharedInstance(callback: ((config: Config) -> Void)!) {
        let config = PFConfig.currentConfig()
        
        if !updating && config.objectForKey("host") != nil {
            callback?(config: Config(config))
        } else {
            Config.update(callback)
        }
    }
    
    class func update(callback: ((config: Config) -> Void)!) {
        updating = true
        
        PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
            updating = false
            
            if config != nil {
                callback?(config: Config(config!))
            } else {
                callback?(config: Config(PFConfig.currentConfig()))
            }
        }
    }
}

