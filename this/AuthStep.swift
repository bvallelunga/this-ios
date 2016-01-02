//
//  AuthStep.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class AuthStep: NSObject {
    
    var value: String = ""
    var placeholder: String = ""
    var title: String = ""
    var percent: CGFloat = 0
    var keyboard: UIKeyboardType = .PhonePad
    var showBack: Bool = true
    var nextText: String = "NEXT"
    var bigText: String = "SURE"
    var background: UIColor = UIColor.blackColor()
    var parentController: AuthController!
    var input: Bool = true
    
    convenience init(parent: AuthController) {
        self.init()
        
        self.parentController = parent
    }
    
    func header() -> String {
        return ""
    }
    
    func formatValue(input: String) -> String {
        self.value = input
        
        return input
    }
    
    func isValid(input: String) -> Bool {
        return true
    }
    
    func next(callback: (segue: Bool, skip: Bool) -> Void) {
        
    }
    
    func button(callback: (segue: Bool, skip: Bool) -> Void) {
    
    }
    
    func viewed() {
    
    }
}
