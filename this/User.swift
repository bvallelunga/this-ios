//
//  User.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

var staticUser: User!

class User: PFUser {
    
    // Instance Variables
    @NSManaged var fullName: String
    @NSManaged var phone: String
    @NSManaged var photo: PFFile
    
    var screenname: String {
        guard self.dataAvailable else {
            return ""
        }
        
        return "@\(self.username!)"
    }
    
    var name: String {
        guard self.dataAvailable else {
            return ""
        }
        
        var name = self.fullName
        
        if name.isEmpty {
            name = self.screenname
        }
        
        return name
    }
    
    // Class Methods
    class func current() -> User! {
        return staticUser != nil ? staticUser : User.currentUser()
    }
    
    override class func logOut() {
        super.logOut()
        
        Globals.landingController.navigationController?.popToRootViewControllerAnimated(false)
    }

    class func verifyNumber(number: String) -> String {
        let code = String(Globals.random(4))
        
        PFCloud.callFunctionInBackground("verifyPhone", withParameters: [
            "phone": number,
            "code": code
        ])
        
        return code
    }
    
    class func logInWithPhone(number: String, callback: (user: User!) -> Void) {
        PFCloud.callFunctionInBackground("loginPhone", withParameters: [
            "phone": number
        ]) { (response, error) -> Void in            
            if let sessionToken = response as? String {
                PFUser.becomeInBackground(sessionToken, block: { (pfuser, error) -> Void in
                    if let user = pfuser as? User {
                        callback(user: user)
                        Installation.setUser(user)
                        user.updateMixpanel()
                    } else if error != nil {
                        ErrorHandler.handleParse(error)
                    } else {
                        callback(user: nil)
                    }
                })
            } else if error == nil {
                callback(user: nil)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func register(username: String, phone: String, callback: (user: User) -> Void) {
        let user = User()
        
        user.username = username
        user.password = NSUUID().UUIDString
        user.phone = phone
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                callback(user: user)
                Installation.setUser(user)
                user.updateMixpanel()
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    // Instance Methods
    override func saveInBackground() -> BFTask {
        return super.saveInBackground().continueWithSuccessBlock({ (task) -> AnyObject? in
            self.updateMixpanel()
            return true
        })
    }
    
    override func saveInBackgroundWithBlock(block: PFBooleanResultBlock?) {
        super.saveInBackgroundWithBlock(block)
        self.updateMixpanel()
    }
    
    func updateMixpanel() {
        Globals.mixpanel.people.set([
            "Parse ID": self.objectId!,
            "$name": self.fullName,
            "$phone": self.phone,
            "$username": self.username!,
            "Profile Picture": self.photo.url != nil
        ])
    }
    
    func uploadPhoto(image: UIImage) {
        let data = UIImageJPEGRepresentation(image, 0.5)
        self.photo = PFFile(name: "image.jpeg", data: data!)!
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                Globals.imageDownloader.setImage(image, forURL: NSURL(string: self.photo.url!))
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func fetchPhoto(callback: (image: UIImage) -> Void) {
        guard let url = self.photo.url else {
            return
        }
        
        Globals.fetchImage(url, callback: callback)
    }
    
    func following(callback: (tags: [Tag]) -> Void) {
        PFCloud.callFunctionInBackground("following", withParameters: nil) { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                callback(tags: tags)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
}
