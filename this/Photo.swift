//
//  Photo.swift
//  this
//
//  Created by Brian Vallelunga on 12/23/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Parse

class Photo: PFObject, PFSubclassing {
    
    // Instance Variables
    @NSManaged var user: User
    @NSManaged var tag: Tag
    @NSManaged var thumbnail: PFFile
    @NSManaged var original: PFFile
    @NSManaged var expireAt: NSDate
    
    static func parseClassName() -> String {
        return "Photo"
    }
    
    // Class Methods
    class func create(user: User, image: UIImage) -> Photo {
        let photo = Photo()
        
        photo.user = user
        
        photo.saveInBackgroundWithBlock { (success, error) -> Void in
            let data = UIImageJPEGRepresentation(image, 0.7)
            
            photo.original = PFFile(name: "image.jpeg", data: data!)!
            photo.saveInBackground()
        }

        return photo
    }

    // Instance Method
    func fetchImage(url: String, callback: (image: UIImage) -> Void) {
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
    
    func fetchThumbnail(callback: (image: UIImage) -> Void) {
        guard let url = self.thumbnail.url else {
            return
        }
        
        self.fetchImage(url, callback: callback)
    }
    
    func fetchOriginal(callback: (image: UIImage) -> Void) {
        guard let url = self.original.url else {
            return
        }
        
        self.fetchImage(url, callback: callback)
    }
}
