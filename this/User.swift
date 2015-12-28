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
        return "@\(username!)"
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
                    } else if error != nil {
                        ErrorHandler.handleParse(error)
                    } else {
                        callback(user: nil)
                    }
                })
            } else if error != nil {
                ErrorHandler.handleParse(error)
            } else {
                callback(user: nil)
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
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    class func findByNumbers(numbers: [String], callback: (users: [User]) -> Void) {
        let query = User.query()
        
        query?.whereKey("phone", containedIn: numbers)
            
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects as? [User] {
                callback(users: users)
            } else {
                ErrorHandler.handleParse(error)
            }
        }
    }
    
    // Instance Methods
    func uploadPhoto(image: UIImage) {
        let data = UIImageJPEGRepresentation(image, 0.7)
        self.photo = PFFile(name: "image.jpeg", data: data!)!
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                Globals.imageStorage.setImage(image, forKey: self.photo.url, diskOnly: false)
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
    
    func tags(callback: (tags: [Tag]) -> Void) {
        let query = Tag.query()
        let photoQuery = Photo.query()
        
        photoQuery?.whereKeyExists("original")
        photoQuery?.whereKey("expireAt", greaterThan: NSDate())
        
        query?.whereKey("followers", equalTo: self)
        query?.whereKey("photos", matchesQuery: photoQuery!)
        query?.addDescendingOrder("updatedAt")
        query?.addDescendingOrder("followerCount")
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                callback(tags: tags)
            } else {
                ErrorHandler.handleParse(error)
            }
        })
    }
}
