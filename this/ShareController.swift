//
//  ShareController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import MessageUI

protocol ShareControllerDelegate {
    func shareControllerShared()
}

class ShareController: UITableViewController, ShareHeaderControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    // TODO: REMOVE WHEN IMPLEMENTING PARSE
    class User: NSObject {
        var name: String = ""
        var username: String = ""
        var phone: String = ""
        
        convenience init(name: String, username: String, phone: String) {
            self.init()
            
            self.name = name
            self.username = username
            self.phone = phone
        }
    }
    
    struct Users {
        var raw: [User] = []
        var filtered: [User] = []
        var selected: [User: Bool] = [:]
    }
    
    struct Contacts {
        var raw: [Contact] = []
        var filtered: [Contact] = []
        var selected: [Contact: Bool] = [:]
    }
    
    var hashtag: String = ""
    var images: [UIImage] = []
    var headerFrame: CGRect!
    var contacts: Contacts = Contacts()
    var users: Users = Users()
    var delegate: ShareControllerDelegate!
    var headerController: ShareHeaderController!

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
        
        self.tableView.delaysContentTouches = false
        
        self.loadContacts()
        self.headerController.updateNextButtonTitle(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.lockPageView()
        self.headerFrame = self.headerController.view.frame
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.unlockPageView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "header" {
            self.headerController = segue.destinationViewController as? ShareHeaderController
            self.headerController?.delegate = self
            self.headerController.hashtag = self.hashtag
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var delta: CGFloat = 0
        var rect = self.headerFrame
        
        if self.tableView.contentOffset.y < 0 {
            delta = fabs(min(0, self.tableView.contentOffset.y))
        }
        
        rect.origin.y -= delta
        rect.size.height += delta
        
        self.headerController.view.frame = rect
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.users.filtered.count : self.contacts.filtered.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && self.users.filtered.isEmpty) || (section == 1 && self.contacts.filtered.isEmpty) {
            return 0
        }
        
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && !self.users.filtered.isEmpty {
            return "SUGGESTED FRIENDS"
        } else if section == 1 && !self.contacts.filtered.isEmpty {
            return "CONTACTS LIST"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "Bariol-Bold", size: 20)
        header.textLabel?.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ShareTableCell
        
        if indexPath.section == 0 {
            let user = self.users.filtered[indexPath.row]
            cell.share = self.users.selected[user] != nil
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = "@\(user.username)"
        } else {
            let contact = self.contacts.filtered[indexPath.row]
            var label = contact.phone.label
            let number = contact.phone.number
            
            if label == nil || label.isEmpty {
                label = ""
            } else {
                label = "\(label): "
            }
            
            cell.textLabel?.text = contact.name
            cell.detailTextLabel?.text = "\(label)\(number)"
            cell.share = self.contacts.selected[contact] != nil
        }
        
        cell.updateAccessory()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ShareTableCell
        
        cell.share = !cell.share
        cell.updateAccessory()
        
        if indexPath.section == 0 {
            let user = self.users.filtered[indexPath.row]
            
            if cell.share {
                self.users.selected[user] = true
            } else {
                self.users.selected.removeValueForKey(user)
            }
        } else {
            let contact = self.contacts.filtered[indexPath.row]
            
            if cell.share {
                self.contacts.selected[contact] = true
            } else {
                self.contacts.selected.removeValueForKey(contact)
            }
        }
        
        self.headerController.updateNextButtonTitle(!self.users.selected.isEmpty || !self.contacts.selected.isEmpty)
    }
    
    func backTriggred() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func nextTriggered() {
        Globals.pagesController.setActiveChildController(2, animated: true, direction: .Forward) { () -> Void in
            self.backTriggred()
            self.delegate.shareControllerShared()
        }
    }
    
    func shareTriggered() {
        guard !self.contacts.selected.isEmpty else {
            self.nextTriggered()
            return
        }
        
        let messageVC = MFMessageComposeViewController()
        var contacts: [String] = []
        let tag = String(self.hashtag.characters.dropFirst())
        
        for contact in self.contacts.selected.keys {
            contacts.append(contact.phone.number)
        }
        
        for image in self.images[0...min(2, self.images.count-1)] {
            let data =  UIImageJPEGRepresentation(image, 0.5)
            messageVC.addAttachmentData(data!, typeIdentifier: "image/jpeg", filename: "\(tag).jpg")
        }
        
        messageVC.recipients = contacts
        messageVC.messageComposeDelegate = self
        messageVC.body = ("Thought it would be cool to share our photos of the event on #this app. " +
            "Join me and post yours on \(self.hashtag) in the app. " +
            "https://getthis.com/tag/\(tag)")
        
        self.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func filterBySearch(var text: String) {
        let numberSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let number = text.componentsSeparatedByCharactersInSet(numberSet).joinWithSeparator("")
        
        if text.isEmpty {
            self.users.filtered = self.users.raw
            self.contacts.filtered = self.contacts.raw
        } else {
            self.users.filtered.removeAll()
            self.contacts.filtered.removeAll()
            
            text = text.lowercaseString
            
            for user in self.users.raw {
                let containsName = NSString(string: user.name.lowercaseString).containsString(text)
                let containsPhone = NSString(string: user.phone).containsString(number)
                let containsUsername = NSString(string: user.username).containsString(text)
                
                if containsName || containsPhone || containsUsername {
                    self.users.filtered.append(user)
                }
            }
            
            for contact in self.contacts.raw {
                let containsName = NSString(string: contact.name.lowercaseString).containsString(text)
                let containsPhone = NSString(string: contact.phone.e164).containsString(number)
                
                if containsName || containsPhone {
                    self.contacts.filtered.append(contact)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func loadContacts() {
        Contact.getContacts { (contacts) -> Void in
            self.contacts.raw = contacts
            self.loadUsers()
        }
    }
    
    func loadUsers() {
        self.users.raw = [
            User(name: "Brian Vallelunga", username: "bvallelunga", phone: "+13108492533"),
            User(name: "Kyle Wu", username: "kwu", phone: "+13108492533")
        ]
        
        self.filterBySearch("")
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if result == MessageComposeResultSent {
                self.nextTriggered()
            }
        }
    }

}
