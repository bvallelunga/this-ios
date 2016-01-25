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

class SelectionCameraController: UIViewController {
    
    var delegate: SelectionCameraControllerDelegate!
    private var cameraView: LLSimpleCamera!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overlay = UIView(frame: self.view.bounds)
        let closeButton = UIButton(frame: CGRectMake(20, 30, 44, 44))
        let instructions = UILabel(frame: CGRectMake(self.view.frame.width/2-90, self.view.frame.height-100, 180, 50))
        
        closeButton.backgroundColor = Colors.lightGrey
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.setTitle("X", forState: .Normal)
        closeButton.titleLabel?.font = UIFont(name: "Bariol-Bold", size: 22)
        closeButton.layer.cornerRadius = 22
        closeButton.layer.masksToBounds = true
        closeButton.layer.borderWidth = 2
        closeButton.layer.borderColor = UIColor(white: 0, alpha: 0.4).CGColor
        closeButton.addTarget(self, action: Selector("close"), forControlEvents: UIControlEvents.AllEvents)
        
        instructions.backgroundColor = Colors.lightGrey
        instructions.textColor = UIColor.whiteColor()
        instructions.text = "Tap To Capture"
        instructions.font = UIFont(name: "Bariol-Bold", size: 22)
        instructions.layer.cornerRadius = 26
        instructions.layer.masksToBounds = true
        instructions.textAlignment = .Center
        instructions.layer.borderWidth = 1
        instructions.layer.borderColor = UIColor(white: 0, alpha: 0.4).CGColor
        
        self.cameraView = LLSimpleCamera(quality: AVCaptureSessionPresetPhoto, position: LLCameraPositionRear, videoEnabled: false)
        self.cameraView.tapToFocus = false
        self.cameraView.start()
        
        self.view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.cameraView.view)
        self.view.addSubview(instructions)
        self.view.addSubview(overlay)
        self.view.addSubview(closeButton)
        
        let tap = UILongPressGestureRecognizer(target: self, action: Selector("tap:"))
        tap.minimumPressDuration = 0.02
        overlay.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: Selector("doubleTap:"))
        doubleTap.numberOfTapsRequired = 2
        overlay.addGestureRecognizer(doubleTap)
        
        tap.requireGestureRecognizerToFail(doubleTap)
    }
    
    func flash() {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        
        Globals.delay(0.2) { () -> () in
            view.removeFromSuperview()
        }
    }
    
    func close() {
        self.delegate.cameraDismiss()
    }
    
    func tap(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == UIGestureRecognizerState.Ended else {
            return
        }
        
        self.flash()
        
        self.cameraView.capture({ (camera, image, meta, error) -> Void in
            camera.start()
            
            if image != nil {
                self.delegate.cameraTaken(image)
            }
        }, exactSeenImage: true)
    }
    
    func doubleTap(gesture: UITapGestureRecognizer) {
        self.cameraView.togglePosition()
    }

}
