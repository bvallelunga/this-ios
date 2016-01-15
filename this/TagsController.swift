//
//  TagsController.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagsController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var followingContainer: UIView!
    @IBOutlet weak var trendingContainer: UIView!
    
    var tag: Tag!
    
    private var followingController: FollowingController!
    private var trendingController: TrendingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Segment
        let attributes = [
            NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 14)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.segment.tintColor = Colors.darkGrey
        self.segment.backgroundColor = UIColor.clearColor()
        self.segment.setTitleTextAttributes(attributes, forState: .Normal)
        self.segment.setTitleTextAttributes(attributes, forState: .Selected)
        
        // Add Bottom Border To Nav Bar
        if let frame = self.navigationController?.navigationBar.frame {
            let navBorder = UIView(frame: CGRectMake(0, frame.height-1, frame.width, 1))
            navBorder.backgroundColor = UIColor(white: 0, alpha: 0.2)
            self.navigationController?.navigationBar.addSubview(navBorder)
        }
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = Colors.lightGrey
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set Background Color
        self.view.backgroundColor = Colors.darkGrey
        self.trendingContainer.backgroundColor = UIColor.clearColor()
        self.followingContainer.backgroundColor = UIColor.clearColor()
        
        // Update Containers
        self.segmentChanged(self)
        
        // Application Became Active
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "applicationDidBecomeActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Core Setup
        Globals.tagsController = self
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!) {
            case "followingContainer":
                self.followingController = segue.destinationViewController as? FollowingController
                self.followingController.parent = self
            
            case "trendingContainer":
                self.trendingController = segue.destinationViewController as? TrendingController
                self.trendingController.parent = self
            
            case "next":
                let controller = segue.destinationViewController as? TagController
                controller?.tag = self.tag
            
            default: break
        }
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        let index = self.segment.selectedSegmentIndex
        let container = index == 0 ? "Following" : "Trending"
        
        self.followingContainer.hidden = index != 0
        self.trendingContainer.hidden = index != 1
        
        Globals.mixpanel.track("Mobile.\(container).Selected")
    }

    @IBAction func goToSelection(sender: AnyObject) {
        Globals.pagesController.setActiveController(1, direction: .Reverse)
    }
    
    func viewTag(tag: Tag) {
        self.tag = tag
        self.performSegueWithIdentifier("next", sender: self)
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        if (self.navigationController?.topViewController == self) {
            self.followingController.reloadTags()
            self.trendingController.reloadTags()
        }
    }

}
