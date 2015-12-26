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
    @IBOutlet var emptyContainer: UIView!
    
    private var headerController: TagHeaderController!
    private var headerFrame: CGRect!
    private var keyboardActive: Bool = false
    private var user = User.current()
    
    var tag: Tag!
    var messages: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.separatorStyle = .None
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
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
            self.headerController.view.clipsToBounds = true
            self.headerController.tag = self.tag
            self.headerController.tagSet()
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
        
        self.headerController.view.frame.size.height = 0
        self.headerContainer.frame.size.height = 0
        self.headerContainer.alpha = 0
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
    }
    
    func keyboardDidHide() {
        self.keyboardActive = false
        
        self.headerContainer.frame = self.headerFrame
        self.headerController.view.frame = self.headerFrame
        self.headerContainer.alpha = 1
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.messages.isEmpty {
            self.tableView.tableFooterView = self.emptyContainer
            self.tableView.separatorStyle = .None
            return 0
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = .SingleLine;
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let message = self.messages[indexPath.row]
        
        cell.textLabel?.attributedText = self.buildText(self.user.screenname, message: message)
        
        return cell
    }
    
    func buildText(user: String, message: String) -> NSAttributedString {
        let text = NSMutableAttributedString(string: user, attributes: [
            NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 20)!,
            NSForegroundColorAttributeName: Colors.greyBlue
        ])
        
        text.appendAttributedString(NSAttributedString(string: " " + message, attributes: [
            NSFontAttributeName: UIFont(name: "Bariol", size: 20)!,
            NSForegroundColorAttributeName: UIColor.blackColor()
        ]))
        
        return text
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        Globals.pagesController.view.endEditing(true)
    }

}
