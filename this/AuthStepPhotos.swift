//
//  AuthStepPhotos.swift
//  this
//
//  Created by Brian Vallelunga on 12/30/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Photos

class AuthStepPhotos: AuthStep {
    
    override init() {
        super.init()
        
        self.title = "PHOTO PERMISSIONS"
        self.nextText = "SKIP"
        self.header = "Last thing.\nCan we share pictures?"
        self.bigText = "ABSOLUTELY"
        self.showBack = false
        self.background = Colors.green
        self.input = false
        self.percent = 1
    }
    
    override func next(callback: (segue: Bool, skip: Bool) -> Void) {
        callback(segue: true, skip: false)
    }
    
    override func button(callback: (segue: Bool, skip: Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                callback(segue: true, skip: false)
            })
        })
    }
    
}