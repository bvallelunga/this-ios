//
//  AuthStepPhone.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import SHSPhoneComponent
import libPhoneNumber_iOS

class AuthStepPhone: AuthStep {
    
    let formatter = SHSPhoneNumberFormatter()
    let phoneUtil = NBPhoneNumberUtil()
    
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
        self.formatter.addOutputPattern("+# (###) ###-##-##", forRegExp: "^7[0-689]\\d*$")
        self.formatter.addOutputPattern("+## (###) ########", forRegExp: "^49\\d*$")
        self.formatter.addOutputPattern("+### (##) ###-###", forRegExp: "^374\\d*$")
    }
    
    override func formatValue(input: String) -> String {
        self.value = input
        
        let response = self.formatter.valuesForString(input)
        
        return response["text"] as! String
    }
    
    override func isValid(input: String) -> Bool {
        let number = try? phoneUtil.parseWithPhoneCarrierRegion(input)
        return phoneUtil.isValidNumber(number)
    }
    
    override func next(callback: (segue: Bool, skip: Bool) -> Void) {
        do {
            let number = try phoneUtil.parseWithPhoneCarrierRegion(self.value)
            let e164 = try phoneUtil.format(number, numberFormat: .E164)
            
            self.parentController.phoneNumber = e164
            self.parentController.phoneVerify = User.verifyNumber(e164)
            
            callback(segue: false, skip: false)
        } catch let error as NSError  {
            print(error.description)
        }
    }

}
