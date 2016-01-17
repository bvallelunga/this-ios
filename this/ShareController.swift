//
//  ShareController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import MessageUI

private let reuseIdentifier = "cell"

protocol ShareControllerDelegate {
    func shareControllerCancelled()
    func shareControllerShared(count: Int)
    func shareControllerInviteCompelete()
}

class ShareController: UITableViewController, ShareHeaderControllerDelegate,
    MFMessageComposeViewControllerDelegate {
    
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
    
    var tag: Tag!
    var backButton = "BACK"
    var images: [UIImage] = []
    var headerFrame: CGRect!
    var contacts: Contacts = Contacts()
    var users: Users = Users()
    var delegate: ShareControllerDelegate!
    var headerController: ShareHeaderController!
    var user = User.current()
    var config: Config!

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
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerFrame = self.headerController.view.frame
        
        Globals.pagesController.lockPageView()
        Globals.mixpanel.track("Mobile.Invite", properties: [
            "tag": self.tag.name,
            "images": self.images.count
        ])
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.unlockPageView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "header" {
            self.headerController = segue.destinationViewController as? ShareHeaderController
            self.headerController?.delegate = self
            self.headerController.tag = self.tag
            self.headerController.backText = self.backButton
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShareTableCell
        
        if indexPath.section == 0 {
            let user = self.users.filtered[indexPath.row]
            
            cell.share = self.users.selected[user] != nil
            cell.updateUser(user, index: indexPath.row)
            
            if !user.fullName.isEmpty {
                cell.textLabel?.text = user.fullName
                cell.detailTextLabel?.text = user.screenname
            } else {
                cell.textLabel?.text = user.screenname
                cell.detailTextLabel?.text = nil
            }
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
            cell.detailTextLabel?.text = "\(label.uppercaseString)\(number)"
            cell.share = self.contacts.selected[contact] != nil
            cell.updateUser(nil, index: indexPath.row)
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
            
            Globals.mixpanel.track("Mobile.Invite.User.\(cell.share ? "S": "Des")elected", properties: [
                "tag": self.tag.name
            ])
        } else {
            let contact = self.contacts.filtered[indexPath.row]
            
            if cell.share {
                self.contacts.selected[contact] = true
            } else {
                self.contacts.selected.removeValueForKey(contact)
            }
            
            Globals.mixpanel.track("Mobile.Invite.Contact.\(cell.share ? "S": "Des")elected", properties: [
                "tag": self.tag.name
            ])
        }
        
        self.headerController.updateNextButtonTitle(!self.users.selected.isEmpty || !self.contacts.selected.isEmpty)
    }
    
    func backTriggered() {
        let count = self.users.selected.count + self.contacts.selected.count
        self.delegate.shareControllerCancelled()
        
        Globals.mixpanel.track("Mobile.Invite.Cancelled", properties: [
            "contacts": self.contacts.selected.count,
            "users": self.users.selected.count,
            "total": count,
            "tag": self.tag.name,
            "images": self.images.count
        ])
    }
    
    func nextTriggered() {
        let count = self.users.selected.count + self.contacts.selected.count
        
        self.delegate.shareControllerShared(count)
        
        Globals.mixpanel.track("Mobile.Invite.Shared", properties: [
            "contacts": self.contacts.selected.count,
            "users": self.users.selected.count,
            "total": count,
            "tag": self.tag.name,
            "images": self.images.count
        ])
    }
    
    func shareTriggered() {
        // Share For Users
        if !self.users.selected.isEmpty {
            self.tag.invite(self.user, users: Array(self.users.selected.keys), callback: { Void in
                self.delegate.shareControllerInviteCompelete()
            })
        }
        
        // Share For Contacts
        guard !self.contacts.selected.isEmpty else {
            self.nextTriggered()
            return
        }
        
        guard MFMessageComposeViewController.canSendText() else {
            UIAlertView(title: "Messaging Not Setup", message: "Please setup text messaging to invite your contacts.",
                delegate: nil, cancelButtonTitle: "Okay").show()
            
            self.nextTriggered()
            return
        }
        
        let messageVC = MFMessageComposeViewController()
        var contacts: [String] = []
        
        for contact in self.contacts.selected.keys {
            contacts.append(contact.phone.number)
        }
        
        if MFMessageComposeViewController.canSendAttachments() {
            if !self.images.isEmpty {
                for image in self.images[0...min(2, self.images.count-1)] {
                    let data =  UIImageJPEGRepresentation(image, 0.5)
                    messageVC.addAttachmentData(data!, typeIdentifier: "image/jpeg", filename: "\(tag).jpg")
                }
            }
        }
        
        messageVC.recipients = contacts
        messageVC.messageComposeDelegate = self
        messageVC.body = String(format: self.config.inviteMessage, self.tag.name, self.tag.name)
        
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
                let containsName = NSString(string: user.fullName.lowercaseString).containsString(text)
                let containsPhone = NSString(string: user.phone).containsString(number)
                let containsUsername = NSString(string: user.username!).containsString(text)
                
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
        
        Globals.mixpanel.track("Mobile.Invite.Search", properties: [
            "tag": self.tag.name,
            "characters": NSString(string: text).length,
            "search": text,
            "images": self.images.count
        ])
        
        self.tableView.reloadData()
    }
    
    func loadContacts() {
        Contact.getContacts(self.user) { (contacts) -> Void in
            self.contacts.raw = contacts
            
            self.filterBySearch("")
            self.loadUsers()
        }
    }
    
    func loadUsers() {
        let numbers = self.contacts.raw.map({ $0.phone.e164 })
        
        self.tag.suggested(numbers) { (users) -> Void in
            Globals.mixpanel.track("Mobile.Invite.Contacts.Fetched", properties: [
                "contacts": self.contacts.raw.count,
                "users": users.count,
                "tag": self.tag.name,
                "images": self.images.count
            ])
            
            self.users.raw = users
            self.intersectionsUsersContacts()
            self.filterBySearch("")
        }
    }
    
    func intersectionsUsersContacts() {
        var contacts: [String: Int] = [:]
        
        for (i, contact) in self.contacts.raw.enumerate() {
            contacts[contact.phone.e164] = i
        }
        
        for user in self.users.raw {
            if let i = contacts[user.phone] {
                contacts.removeValueForKey(user.phone)
                self.contacts.raw.removeAtIndex(i)
            }
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if result == MessageComposeResultSent {
                self.nextTriggered()
            }
        }
    }

}
