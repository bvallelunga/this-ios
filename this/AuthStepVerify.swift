//
//  AuthStepVerify.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class AuthStepVerify: AuthStep {
    
    override init() {
        super.init()
        
        self.value = ""
        self.placeholder = "• • • •"
        self.title = "TEXT VERIFICATION"
        self.header = "Did I get it right?\nI sent you a code."
        self.showBack = true
        self.keyboard = .NumberPad
        self.background = Colors.purple
        self.percent = 0.5
    }
    
    override func formatValue(input: String) -> String {
        self.value = input.stringByReplacingOccurrencesOfString(" ", withString: "",
            options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let chars = self.value.characters.map { String($0) }
        
        if chars.isEmpty {
            return ""
        }
        
        return chars[0...min(chars.count-1, 3)].joinWithSeparator(" ")
    }
    
    override func isValid(var input: String) -> Bool {
        input = input.stringByReplacingOccurrencesOfString(" ", withString: "",
            options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return true //self.parentController.phoneVerify == input
    }
    
    override func next(callback: (segue: Bool) -> Void) {
        callback(segue: false)
    }

}
