//
//  ShareGenerator.swift
//  this
//
//  Created by Brian Vallelunga on 12/21/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ShareGenerator {
    
    class func share(text: String, image: UIImage!) -> UIActivityViewController {
        var sharingItems = [AnyObject]()
        
        sharingItems.append(text)
        
        if image != nil {
            sharingItems.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [])
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypeAssignToContact,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToVimeo
        ]
        
        return activityViewController
    }
}