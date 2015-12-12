//
//  AuthStepPhone.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import SHSPhoneComponent
import PhoneNumberKit

class AuthStepPhone: AuthStep {
    
    let formatter = SHSPhoneNumberFormatter()
    let logic = SHSPhoneLogic()
    
    override init() {
        super.init()
        
        self.value = "+1 "
        self.title = "ACCOUNT"
        self.header = "Hey, can I\nget your number?"
        self.showBack = false
        self.keyboard = .PhonePad
        self.background = Colors.offBlue
        self.percent = 0.25
        self.placeholder = "+1"
        self.formatter.setDefaultOutputPattern("+# (###) ###-####")
    }
    
    override func formatValue(input: String) -> String {
        self.value = input
        
        let response = self.formatter.valuesForString(input)
        
        return response["text"] as! String
    }
    
    override func isValid(input: String) -> Bool {
        do {
            try PhoneNumber(rawNumber: input)
        } catch {
            return false
        }
        
        return true
    }
    
    override func next(callback: (segue: Bool) -> Void) {
        callback(segue: false)
    }

}
