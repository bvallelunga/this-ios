//
//  TagTableController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TagTableController: UITableViewController, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet var emptyContainer: UIView!
    
    var headerController: TagHeaderController!
    var tag: Tag!
    var comments: [Comment] = []
    
    private var headerFrame = CGRect.zero
    private var keyboardActive = false
    private var user = User.current()
    private var commentHeights: [NSIndexPath: CGFloat] = [:]

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
        
        let press = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        press.minimumPressDuration = 1
        self.tableView.addGestureRecognizer(press)
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.lightGrayColor()
        self.refreshControl?.addTarget(self, action: Selector("reloadTag"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
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
        }
    }
    
    func reloadTag() {
        Globals.tagController.updateTag(self.tag)
        self.refreshControl?.endRefreshing()
    }
    
    func updateTag(tag: Tag) {
        self.tag = tag
        self.reloadComments()
        self.headerController?.updateTag(tag)
    }
    
    func reloadComments() {
        self.tag.comments { (comments) -> Void in
            self.comments = comments
            self.tableView.reloadData()
            
            Globals.mixpanel.track("Mobile.Tag.Comments.Fetched", properties: [
                "tag": self.tag.name,
                "comments": comments.count
            ])
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
        self.tableView.tableFooterView = self.tableView.tableFooterView
    }
    
    func keyboardDidHide() {
        self.keyboardActive = false
        
        self.headerContainer.frame = self.headerFrame
        self.headerController.view.frame = self.headerFrame
        self.headerContainer.alpha = 1
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
        self.tableView.tableFooterView = self.tableView.tableFooterView
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.comments.isEmpty {
            self.tableView.tableFooterView = self.emptyContainer
            self.tableView.separatorStyle = .None
            return 0
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorStyle = .SingleLine;
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TagTableCell
        let comment = self.comments[indexPath.row]
        let message = self.buildText(comment.from, message: comment.message)
        let linkAttrs: [NSObject: AnyObject] = [
            kCTForegroundColorAttributeName: Colors.greyBlue,
            NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 20)!,
        ]
        let range = NSString(string: message).rangeOfString(comment.from)
        
        cell.label.delegate = self
        cell.label.linkAttributes = linkAttrs
        cell.label.activeLinkAttributes = linkAttrs
        cell.label.inactiveLinkAttributes = linkAttrs
        cell.label.text = self.buildText(comment.from, message: comment.message) as String
        cell.label.numberOfLines = 0
        cell.label.lineBreakMode = .ByWordWrapping
        cell.label.addLinkToURL(NSURL(string: "this://\(comment.user.objectId!)"), withRange: range)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = self.commentHeights[indexPath] {
            return height
        }
        
        let comment = self.comments[indexPath.row]
        let message = self.buildText(comment.from, message: comment.message)
        let maxLabelSize = CGSizeMake(tableView.frame.width, 400)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        let bounds = message.boundingRectWithSize(maxLabelSize, options: options, attributes: nil, context: nil)
        let height = bounds.size.height + 20
        self.commentHeights[indexPath] = height
        
        return height
    }
    
    func scrollToBottom() {
        guard !self.comments.isEmpty else {
            return
        }
        
        let indexPath = NSIndexPath(forRow: self.comments.count-1, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func buildText(user: String, message: String) -> NSString {
        return user + " " + message
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        Globals.pagesController.view.endEditing(true)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.locationInView(self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        
        let controller = UIAlertController(title: "Flag Comment?",
            message: "Please confirm that this comment should be flagged.",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            self.comments[indexPath.row].flag()
            self.comments.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            
            Globals.mixpanel.track("Mobile.Tag.Comment.Flagged", properties: [
                "tag": self.tag.name,
                "comments": self.comments.count
            ])
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {        
        let controller = Globals.storyboard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
        controller.user = User(withoutDataWithObjectId: url.host)
        Globals.tagController.navigationController?.pushViewController(controller, animated: true)
    }

}
