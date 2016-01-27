//
//  TagController.swift
//  this
//
//  Created by Brian Vallelunga on 12/16/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var tag: Tag!
    private var user = User.current()
    private var tableController: TagTableController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.messageInput.delegate = self
        self.sendButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        self.messageChanged(self)
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2)
        
        if let font = UIFont(name: "Bariol-Bold", size: 26) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        self.updateTag(self.tag)
        Globals.mixpanel.track("Mobile.Tag", properties: [
            "tag": self.tag.name
        ])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.tagController = self
        Globals.pagesController.lockPageView()
        
        // Register for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.tagController = nil
        Globals.pagesController.unlockPageView()
        
        // Unregister for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "table" {
            self.tableController = segue.destinationViewController as? TagTableController
        }
    }
    
    @IBAction func uploadTriggerd(sender: AnyObject) {
        Globals.selectionController.setHashtag(self.tag.hashtag)
        Globals.pagesController.setActiveController(1, direction: .Reverse) { () -> Void in
            self.navigationController?.popViewControllerAnimated(false)
        }
        Globals.mixpanel.track("Mobile.Tag.Selection Button", properties: [
            "tag": self.tag.name,
            "comments": self.tableController.comments.count,
            "images": self.tag.photoCount
        ])
    }

    @IBAction func postMessage(sender: AnyObject) {
        if let message = self.messageInput.text {
            guard !message.isEmpty else {
                return
            }
            
            self.messageInput.text = ""
            let comment = Comment.create(message, tag: self.tag, user: self.user)
            
            self.tableController.comments.append(comment)
            self.tableController.tableView.reloadData()
            self.tableController.scrollToBottom()
            self.messageChanged(self)
            
            Globals.mixpanel.track("Mobile.Tag.Comment.Posted", properties: [
                "tag": self.tag.name,
                "comments": self.tableController.comments.count,
                "images": self.tag.photoCount
            ])
        }
    }
    
    @IBAction func messageChanged(sender: AnyObject) {
        self.sendButton.enabled = !self.messageInput.text!.isEmpty
    }
    
    func updateTag(tag: Tag) {
        self.tag = tag
        self.title = tag.hashtag
        self.tableController?.updateTag(tag)
        StateTracker.clearTagNotification(self.tag)
    }
    
    func updateComments() {
        self.tableController.reloadComments()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.postMessage(self)
        return true
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        guard self.presentedViewController == nil else {
            return
        }
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        
        self.bottomConstraint.constant = rect.size.height
        self.view.layoutIfNeeded()
        
        Globals.delay(0.25) { () -> () in
            self.tableController.scrollToBottom()
        }
    }
    
    func keyboardDidHide() {
        guard self.presentedViewController == nil else {
            return
        }
        
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }

}
