//
//  TagController.swift
//  this
//
//  Created by Brian Vallelunga on 12/16/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagController: UIViewController {

    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var hashtag: String = "#blackcat15"
    private var tableController: TagTableController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.hashtag
        self.view.backgroundColor = UIColor.whiteColor()
        
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.lockPageView()
        
        // Register for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        Globals.selectionController.setHashtag(self.hashtag)
        Globals.pagesController.setActiveController(1, direction: .Reverse)
    }

    @IBAction func postMessage(sender: AnyObject) {
        self.tableController.messages.append(self.messageInput.text!)
        self.tableController.tableView.reloadData()
        
        self.messageInput.text = ""
        self.messageInput.resignFirstResponder()
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        
        self.bottomConstraint.constant = rect.size.height
        self.view.layoutIfNeeded()
    }
    
    func keyboardDidHide() {
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }

}
