//
//  SelectionCameraCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import LLSimpleCamera

class SelectionCameraCell: UICollectionViewCell {
    
    var cameraView: LLSimpleCamera!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = Colors.darkGrey
        
        self.cameraView = LLSimpleCamera(quality: AVCaptureSessionPresetLow, position: LLCameraPositionRear, videoEnabled: false)
        self.cameraView.tapToFocus = false
        self.cameraView.view.frame = self.bounds
        self.cameraView.view.userInteractionEnabled = false
        
        let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if cameraStatus == .NotDetermined  {
            self.cameraView.view.hidden = true
        } else {
            self.cameraView.start()
        }
        
        let iconViewer = UIImageView(frame: self.bounds)
        iconViewer.tintColor = UIColor.whiteColor()
        iconViewer.alpha = 0.8
        iconViewer.image = UIImage(named: "Small Camera")
        iconViewer.contentMode = .ScaleAspectFit
        iconViewer.layer.shadowColor = UIColor.blackColor().CGColor
        iconViewer.layer.shadowOffset = CGSizeMake(0, 1)
        iconViewer.layer.shadowOpacity = 0.4
        iconViewer.layer.shadowRadius = 0
        
        self.addSubview(self.cameraView.view)
        self.addSubview(iconViewer)
    }
    
    func activateCamera() {
        self.cameraView.view.hidden = false
        self.cameraView.start()
    }
    
}
