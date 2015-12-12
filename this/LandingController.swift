//
//  LandingController.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class LandingController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var legalLabel: UILabel!
    
    private var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Logo
        self.logoLabel.shadowColor = UIColor(white: 0, alpha: 0.2)
        self.logoLabel.shadowOffset = CGSizeMake(0, 2)
        
        // Setup Legal
        self.legalLabel.alpha = 0.8
        
        // Setup Button
        self.button.backgroundColor = UIColor(red:0, green:0.78, blue:0.98, alpha:1)
        self.button.tintColor = UIColor.whiteColor()
        self.button.layer.cornerRadius = 30
        self.button.layer.shadowColor = UIColor.blackColor().CGColor
        self.button.layer.shadowOffset = CGSizeMake(0, 3)
        self.button.layer.shadowRadius = 3
        self.button.layer.shadowOpacity = 0.3
        
        // Setup Movie
        let videoURL = NSBundle.mainBundle().URLForResource("VideoBackground", withExtension: "mp4")
        let playerItem = AVPlayerItem(asset: AVAsset(URL: videoURL!))
        self.player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: self.player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.view.layer.insertSublayer(playerLayer, atIndex: 0)
        self.player.actionAtItemEnd = .None
        self.player.volume = 0
        
        // Enable Movie Looping
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerRestart:"), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func playerRestart(notification: NSNotification) {
        self.player.currentItem?.seekToTime(kCMTimeZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.pause()
    }

}
