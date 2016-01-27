//
//  AuthStepUsername.swift
//  this
//
//  Created by Brian Vallelunga on 12/12/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class AuthStepUsername: AuthStep {
    
    override init() {
        super.init()
        
        self.value = ""
        self.placeholder = "@username"
        self.title = "USERNAME"
        self.nextText = "SIGN UP"
        self.showBack = true
        self.keyboard = .Twitter
        self.background = Colors.greyBlue
        self.percent = 0.75
    }
    
    override func header() -> String {
        return "Chill. What\nshould I call you?"
    }
    
    override func viewed() {
        Globals.mixpanel.track("Mobile.Auth.Username")
    }
    
    override func formatValue(input: String) -> String {
        let alphaNumberSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        
        self.value = input.stringByReplacingOccurrencesOfString(" ", withString: "",
            options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if self.value.isEmpty {
            return ""
        }
        
        self.value = "@" + self.value.lowercaseString
            .componentsSeparatedByCharactersInSet(alphaNumberSet)
            .joinWithSeparator("")
        
        return self.value
    }
    
    override func isValid(input: String) -> Bool {
        return NSString(string: input).length > 1
    }
    
    override func next(callback: (segue: Bool, skip: Bool) -> Void) {
        let username = String(self.value.characters.dropFirst())
        
        self.parentController.nextButton.enabled = false
        
        User.register(username, phone: self.parentController.phoneNumber, callback: { (user) -> Void in
            Globals.mixpanel.track("Mobile.Auth.Registered")
            callback(segue: false, skip: false)
        }, hasError: { () -> Void in
            self.parentController.nextButton.enabled = true
        })
    }

}
