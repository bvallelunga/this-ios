//
//  SelectionCameraController.swift
//  this
//
//  Created by Brian Vallelunga on 1/25/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit
import LLSimpleCamera

protocol SelectionCameraControllerDelegate {
    func cameraDismiss()
    func cameraTaken(image: UIImage)
}

class SelectionCameraController: UIViewController, UIGestureRecognizerDelegate {
    
    var delegate: SelectionCameraControllerDelegate!
    var cameraView: LLSimpleCamera!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = self.view.bounds
        let overlay = UIView(frame: bounds)
        let bottom = UILabel(frame: CGRectMake(0, bounds.height-55, bounds.width, 35))
        let instructions = UILabel(frame: CGRectMake(bounds.width/2-80, bounds.height-100, 160, 45))
        
        bottom.textColor = UIColor.whiteColor()
        bottom.text = "HOLD TO SWAP CAMERA"
        bottom.font = UIFont(name: "Bariol-Bold", size: 18)
        bottom.textAlignment = .Center
        bottom.shadowColor = UIColor(white: 0, alpha: 0.7)
        bottom.shadowOffset = CGSize(width: 0, height: 1)
        
        instructions.backgroundColor = UIColor.blackColor()
        instructions.textColor = UIColor.whiteColor()
        instructions.text = "Double Tap"
        instructions.font = UIFont(name: "Bariol-Bold", size: 22)
        instructions.layer.cornerRadius = 23
        instructions.layer.masksToBounds = true
        instructions.textAlignment = .Center
        instructions.layer.borderWidth = 1
        instructions.layer.borderColor = UIColor(white: 0, alpha: 0.4).CGColor
        
        self.cameraView = LLSimpleCamera(quality: AVCaptureSessionPresetPhoto, position: LLCameraPositionFront, videoEnabled: false)
        self.cameraView.tapToFocus = false
        self.cameraView.updateFlashMode(LLCameraFlashAuto)
        
        self.view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.cameraView.view)
        self.view.addSubview(instructions)
        self.view.addSubview(bottom)
        self.view.addSubview(overlay)
        
        let closeCamera = UITapGestureRecognizer(target: self, action: Selector("closeCamera:"))
        closeCamera.numberOfTapsRequired = 1
        overlay.addGestureRecognizer(closeCamera)
        
        let takePhoto = UITapGestureRecognizer(target: self, action: Selector("takePhoto:"))
        takePhoto.numberOfTapsRequired = 2
        overlay.addGestureRecognizer(takePhoto)
        
        let switchCamera = UILongPressGestureRecognizer(target: self, action: Selector("switchCamera:"))
        switchCamera.minimumPressDuration = 0.25
        overlay.addGestureRecognizer(switchCamera)
        
        closeCamera.requireGestureRecognizerToFail(takePhoto)
        
        Globals.delay(5) { () -> () in
            bottom.text = "TAP TO CLOSE"
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func flash() {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        
        Globals.delay(0.2) { () -> () in
            view.removeFromSuperview()
        }
    }
    
    func closeCamera(gesture: UITapGestureRecognizer) {
        self.delegate.cameraDismiss()
    }
    
    func takePhoto(gesture: UITapGestureRecognizer) {
        self.flash()
        
        self.cameraView.capture({ (camera, image, meta, error) -> Void in
            camera.start()
            
            if image != nil {
                self.delegate.cameraTaken(image)
            }
        }, exactSeenImage: true)
    }
    
    func switchCamera(gesture: UITapGestureRecognizer) {
        guard gesture.state == UIGestureRecognizerState.Began else {
            return
        }
        
        self.cameraView.togglePosition()
    }

}
