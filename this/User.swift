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
    @NSManaged var friends: PFRelation
    
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
        
        Globals.mixpanel.track("Mobile.User.Logout")
        Globals.mixpanel.reset()
        
        Globals.landingController.navigationController?.popToRootViewControllerAnimated(false)
    }

    class func verifyNumber(number: String, callback: (code: String, username: String!) -> Void, hasError: () -> Void) {
        let code = String(Globals.random(4))
        
        PFCloud.callFunctionInBackground("verifyPhone", withParameters: [
            "phone": number,
            "code": code
        ]) { (response, error) -> Void in
            if error == nil {
                callback(code: code, username: response as? String)
            } else {
                hasError()
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func logInWithPhone(number: String, callback: (user: User!) -> Void, hasError: () -> Void) {
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
                hasError()
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func register(username: String, phone: String, callback: (user: User) -> Void, hasError: () -> Void) {
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
                hasError()
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func find(text: String, callback: (users: [User]) -> Void) {
        let usernameQuery = User.query()!
        let nameQuery = User.query()!
        let phoneQuery = User.query()!
        let queries: [PFQuery] = [usernameQuery, nameQuery, phoneQuery]
        let regex = ".*\(text).*"
        
        usernameQuery.whereKey("username", matchesRegex: regex, modifiers: "i")
        nameQuery.whereKey("fullName", matchesRegex: regex, modifiers: "i")
        phoneQuery.whereKey("phone", matchesRegex: regex, modifiers: "i")
        
        PFQuery.orQueryWithSubqueries(queries).findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects as? [User] {
                callback(users: users)
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
            "$name": self.name,
            "$phone": self.phone,
            "$username": self.username!,
            "Profile Picture": self.photo.url != nil
        ])
        
        Globals.mixpanel.registerSuperProperties([
            "User ID": self.objectId!,
            "User": self.name
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
        PFCloud.callFunctionInBackground("following", withParameters: [
            "user": self.objectId!
        ]) { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                callback(tags: tags)
            } else {
                callback(tags: [])
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    func addFriends(numbers: [String]) {
        let query = User.query()
        
        query?.whereKey("phone", containedIn: numbers)
        query?.whereKey("objectId", doesNotMatchKey: "objectId", inQuery: self.friends.query())
        
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects as? [User] {
                for user in users {
                    self.friends.addObject(user)
                }
                
                self.saveInBackground()
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
}
