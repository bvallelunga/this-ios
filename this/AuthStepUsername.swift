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
        self.header = "Chill. What\nshould I call you?"
        self.showBack = true
        self.keyboard = .Twitter
        self.background = Colors.greyBlue
        self.percent = 0.75
    }
    
    override func formatValue(input: String) -> String {
        self.value = input
        
        if self.value.isEmpty {
            return ""
        }
        
        if self.value[0] != "@" {
            self.value = "@" + self.value
        }
        
        return self.value
    }
    
    override func isValid(input: String) -> Bool {
        return NSString(string: input).length > 0
    }
    
    override func next(callback: (segue: Bool) -> Void) {
        callback(segue: true)
    }

}
