//
//  ErrorHandler.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import Parse

class ErrorHandler {
    class func handleParse(error: NSError!) {
        guard error != nil && error.domain == PFParseErrorDomain else {
            return
        }
        
        switch (error.code) {
        case PFErrorCode.ErrorInvalidSessionToken.rawValue:
            self.handleInvalidSessionTokenError()
            
        case PFErrorCode.ErrorUserCannotBeAlteredWithoutSession.rawValue:
            self.handleInvalidSessionTokenError()
            
        case PFErrorCode.ErrorUsernameTaken.rawValue:
            NavNotification.show("Username Taken 😢")
            Globals.mixpanel.track("Mobile.Auth.Register.Username Taken")
            
        default: print(error)
        }
    }
    
    private class func handleInvalidSessionTokenError() {
        User.logOut()
        Globals.mixpanel.track("Mobile.Auth.Force Logout")
    }
}