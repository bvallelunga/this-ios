//
//  TagHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagHeaderController: UIViewController, ShareControllerDelegate {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var followersCollection: TagHeaderProfiles!
    
    var tag: Tag!
    var downloadMode: Bool = false
    var pageController: TagHeaderPages!
    
    private var config: Config!
    private var user = User.current()
    private var following: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.darkGrey
        
        self.setupButton(self.followingButton, color: Colors.lightGrey)
        self.setupButton(self.inviteButton, color: Colors.green)
        self.inviteButton.tintColor = UIColor.whiteColor()
        self.downloadButton.tintColor = UIColor.whiteColor()
        self.updateFollowingButton()
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pagesContainer" {
            self.pageController = segue.destinationViewController as? TagHeaderPages
            self.pageController.parent = self
        }
    }
    
    func updateTag(tag: Tag) {
        self.tag = tag
        
        self.pageController.updateTag(tag)
        self.followersCollection.updateTag(tag)
        
        self.tag.isUserFollowing(self.user) { (following) -> Void in
            self.following = following
            self.updateFollowingButton()
            
            Globals.mixpanel.track("Mobile.Tag.isFollowing", properties: [
                "tag": self.tag.name,
                "images": self.tag.photoCount,
                "following": following
            ])
        }
    }
    
    func updateFollowingButton() {
        guard let following = self.following else {
            self.followingButton.setTitle("LOADING", forState: .Normal)
            self.followingButton.tintColor = Colors.darkGrey
            self.followingButton.backgroundColor = Colors.lightGrey
            
            return
        }
        
        let text = following ? "FOLLOWING" : "FOLLOW"
        self.followingButton.tintColor = UIColor.whiteColor()
        self.followingButton.backgroundColor = Colors.blue
        self.followingButton.setTitle(text, forState: .Normal)
    }
    
    func setupButton(button: UIButton, color: UIColor) {
        button.backgroundColor = color
        button.layer.cornerRadius = 3
    }

    @IBAction func downloadTriggered(sender: AnyObject) {
        self.downloadMode = !self.downloadMode
        self.downloadButton.tintColor = self.downloadMode ? Colors.blue : UIColor.whiteColor()
        self.pageController.downloadMode(self.downloadMode)
    }
    
    @IBAction func inviteTriggered(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("ShareController") as! ShareController
        
        controller.delegate = self
        controller.images = self.pageController.images
        controller.tag = self.tag
        controller.backButton = "CANCEL"
        
        self.presentViewController(controller, animated: true, completion: nil)
        
        Globals.mixpanel.track("Mobile.Tag.Invite Button", properties: [
            "tag": self.tag.name,
            "images": controller.images.count
        ])
    }

    @IBAction func followingTriggered(sender: AnyObject) {
        guard var following = self.following else {
            return
        }
        
        following = !following
        
        if following {
            self.tag.followers.addObject(self.user)
        } else {
            self.tag.followers.removeObject(self.user)
        }
        
        self.tag.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                Globals.followingController.reloadTags()
            } else {
                ErrorHandler.handleParse(error)
            }
        }
        
        self.following = following
        self.updateFollowingButton()
        
        Globals.mixpanel.track("Mobile.Tag.Following.Changed", properties: [
            "tag": self.tag.name,
            "images": self.tag.photoCount,
            "following": following
        ])
    }
    
    func shareControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareControllerShared(count: Int) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
