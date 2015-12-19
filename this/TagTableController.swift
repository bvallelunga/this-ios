//
//  TagTableController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagTableController: UITableViewController {
    
    
    @IBOutlet weak var headerContainer: UIView!
    
    private var headerController: TagHeaderController!
    private var headerFrame: CGRect!
    private var keyboardActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = .None
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let percent: CGFloat = 0.8
        self.headerContainer.frame.size.height = self.view.frame.height * percent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerFrame = self.headerContainer.frame
        
        // Register for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Unregister for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "header" {
            self.headerController = segue.destinationViewController as? TagHeaderController
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.keyboardActive {
            return
        }
        
        var delta: CGFloat = 0
        var rect = self.headerFrame
        
        if self.tableView.contentOffset.y < 0 {
            delta = fabs(min(0, self.tableView.contentOffset.y))
        }
        
        rect.origin.y -= delta
        rect.size.height += delta
        
        self.headerController.view.frame = rect
    }
    
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        self.keyboardActive = true
    
        UIView.animateWithDuration(0.1) { () -> Void in
            self.headerController.view.frame.size.height = 0
            self.headerContainer.frame.size.height = 0
            self.headerContainer.alpha = 0
        }
    }
    
    func keyboardDidHide() {
        self.keyboardActive = false
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.headerContainer.frame = self.headerFrame
            self.headerController.view.frame = self.headerFrame
            self.headerContainer.alpha = 1
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        Globals.pagesController.view.endEditing(true)
    }

}
