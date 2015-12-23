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
    @NSManaged var following: [Tag]
    
    // Parse Setup
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
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
    
    class func logInWithPhone(number: String, callback: (user: User) -> Void) {
        PFCloud.callFunctionInBackground("loginPhone", withParameters: [
            "phone": number
        ]) { (response, error) -> Void in
            if let sessionToken = response as? String {
                PFUser.becomeInBackground(sessionToken, block: { (pfuser, error) -> Void in
                    if let user = pfuser as? User {
                        callback(user: user)
                    } else {
                        ErrorHandler.handleParse(error!)
                    }
                })
            } else {
                ErrorHandler.handleParse(error!)
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
                ErrorHandler.handleParse(error!)
            }
        }
    }
    
    class func numberExists(number: String, callback: (exists: Bool) -> Void) {
        let query = User.query()
        
        query?.whereKey("phone", equalTo: number)
        
        query?.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
            if error == nil {
                callback(exists: count > 0)
            } else {
                ErrorHandler.handleParse(error)
            }
        })
    }
    
    // Instance Methods
    func uploadPhoto(image: UIImage) {
        let data = UIImageJPEGRepresentation(image, 0.7)
        self.photo = PFFile(name: "image.jpeg", data: data!)!
        self.saveInBackground()
    }
    
    func fetchPhoto(callback: (image: UIImage) -> Void) {
        guard let url = self.photo.url else {
            return
        }
        
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        if let image = Globals.imageCache.imageForRequest(request) {
            callback(image: image)
            return
        }
        
        Globals.imageDownloader.downloadImage(URLRequest: request) { response in
            if let image: UIImage = response.result.value {
                callback(image: image)
                    
                Globals.imageCache.addImage(image, forRequest: request)
            } else {
                print(response)
            }
        }
    }

}
