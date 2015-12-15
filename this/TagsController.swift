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
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Remove Text From Back Button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000),
            forBarMetrics: UIBarMetrics.Default)
        
        // Set Background Color
        self.view.backgroundColor = Colors.darkGrey

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func segmentChanged(sender: AnyObject) {
    }

    @IBAction func goToSelection(sender: AnyObject) {
        Globals.pagesController.setActiveChildController(1, animated: true, direction: .Reverse, callback: nil)
    }

}
