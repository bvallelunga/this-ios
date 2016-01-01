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
import SVProgressHUD
import TTTAttributedLabel

class LandingController: UIViewController, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var legalLabel: TTTAttributedLabel!
    
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check If User Is Logged In
        if let user = User.current() {
            self.performSegueWithIdentifier("next", sender: self)
            Installation.setUser(user)
        }

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
        
        // Remove Text From Back Button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000),
            forBarMetrics: UIBarMetrics.Default)
        
        // Enable Movie Looping
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerRestart:"), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // Setup Legal
        Config.sharedInstance { (config) -> Void in
            let tos = NSURL(string: config.termsURL)
            let privacy = NSURL(string: config.privacyURL)
            let linkAttrs: [NSObject: AnyObject] = [
                kCTForegroundColorAttributeName: Colors.blue,
                NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 13)!,
            ]
            
            let tosRange = NSString(string: self.legalLabel.text!).rangeOfString("Terms of Service")
            let privacyRange = NSString(string: self.legalLabel.text!).rangeOfString("Privacy Policy")
            
            self.legalLabel.delegate = self
            self.legalLabel.linkAttributes = linkAttrs
            self.legalLabel.activeLinkAttributes = linkAttrs
            self.legalLabel.inactiveLinkAttributes = linkAttrs
            self.legalLabel.addLinkToURL(tos, withRange: tosRange)
            self.legalLabel.addLinkToURL(privacy, withRange: privacyRange)
        }
        
        // Setup Progress Hub
        SVProgressHUD.setBackgroundColor(Colors.darkGrey)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setFont(UIFont(name: "Bariol-Bold", size: 22))
        
        // Core Setup
        Globals.landingController = self
        Globals.mixpanel.track("Mobile.Landing")
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
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        Globals.presentBrowser(url, sender: self)
    }

}
