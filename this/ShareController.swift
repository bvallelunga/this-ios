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

class ShareController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    ShareHeaderControllerDelegate, MFMessageComposeViewControllerDelegate {
    
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
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var tag: Tag!
    var backButton = "CANCEL"
    var images: [UIImage] = []
    var headerFrame: CGRect!
    var contacts: Contacts = Contacts()
    var users: Users = Users()
    var friends: Users = Users()
    var delegate: ShareControllerDelegate!
    var headerController: ShareHeaderController!
    var user = User.current()
    var config: Config!
    var messageImage: UIImage!
    var keyboardActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1)
        self.tableView.delaysContentTouches = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapper.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapper)
        
        self.loadContacts()
        self.headerController.updateNextButtonTitle(false)
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
        
        if MFMessageComposeViewController.canSendAttachments() {
            if !self.images.isEmpty {
                let images = Array(self.images.shuffle()[0...min(4, self.images.count-1)])
                self.messageImage = self.collageImage(CGRect(x: 0, y: 0, width: 1000, height: 1000), images: images)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerFrame = self.headerController.view.frame
        
        // Register for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide"), name:UIKeyboardWillHideNotification, object: nil)
        
        Globals.pagesController.lockPageView()
        Globals.mixpanel.track("Mobile.Invite", properties: [
            "tag": self.tag.name,
            "images": self.images.count
        ])
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var delta: CGFloat = 0
        var rect = self.headerFrame
        
        guard !self.keyboardActive else {
            return
        }
        
        if self.tableView.contentOffset.y < 0 {
            delta = fabs(min(0, self.tableView.contentOffset.y))
            
            rect.origin.y -= delta
            rect.size.height += delta
        }
        
        self.headerController.view.frame = rect
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        
        self.keyboardActive = true
        self.tableView.contentInset.top = 66
        self.tableView.contentInset.bottom = rect.size.height
        self.tableView.tableHeaderView = nil
        self.view.addSubview(self.headerContainer)
        self.headerController.searchBar.becomeFirstResponder()
        self.headerContainer.frame.origin.y = 66 - self.headerFrame.height
    }
    
    func keyboardDidHide() {
        self.keyboardActive = false
        self.tableView.contentInset.top = 0
        self.headerContainer.removeFromSuperview()
        
        self.tableView.tableHeaderView = self.headerContainer
        self.headerContainer.frame = self.headerFrame
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return self.users.filtered.count
            case 1: return self.friends.filtered.count
            default: return self.contacts.filtered.count
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
            case 0: return self.users.filtered.isEmpty ? 0.1 : 20
            case 1: return self.friends.filtered.isEmpty ? 0.1 : 20
            default: return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 0: return self.users.filtered.isEmpty ? 0.1 : 40
            case 1: return self.friends.filtered.isEmpty ? 0.1 : 40
            default: return self.contacts.filtered.isEmpty ? 0.1 : 40
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && !self.users.filtered.isEmpty {
            return "PEOPLE"
        } else if section == 1 && !self.friends.filtered.isEmpty {
            return "FRIENDS"
        } else if section == 2 && !self.contacts.filtered.isEmpty {
            return "CONTACTS"
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "Bariol-Bold", size: 20)
        header.textLabel?.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1)
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        
        footer.contentView.backgroundColor = UIColor.whiteColor()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShareTableCell
        
        if indexPath.section < 2 {
            let users = indexPath.section == 0 ? self.users.filtered : self.friends.filtered
            let selected = indexPath.section == 0 ? self.users.selected : self.friends.selected
            let user = users[indexPath.row]
            
            cell.share = selected[user] != nil
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
        } else if indexPath.section == 1 {
            let user = self.friends.filtered[indexPath.row]
            
            if cell.share {
                self.friends.selected[user] = true
            } else {
                self.friends.selected.removeValueForKey(user)
            }
            
            Globals.mixpanel.track("Mobile.Invite.Friend.\(cell.share ? "S": "Des")elected", properties: [
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
        
        self.headerController.updateNextButtonTitle(
            !self.users.selected.isEmpty ||
            !self.friends.selected.isEmpty ||
            !self.contacts.selected.isEmpty
        )
    }
    
    func backTriggered() {
        let count = self.users.selected.count +
                    self.contacts.selected.count +
                    self.friends.selected.count
        
        self.delegate.shareControllerCancelled()
        
        Globals.mixpanel.track("Mobile.Invite.Cancelled", properties: [
            "contacts": self.contacts.selected.count,
            "users": self.users.selected.count,
            "friends": self.friends.selected.count,
            "total": count,
            "tag": self.tag.name,
            "images": self.images.count
        ])
    }
    
    func nextTriggered() {
        let count = self.users.selected.count +
                    self.contacts.selected.count +
                    self.friends.selected.count
        
        self.delegate.shareControllerShared(count)
        
        Pending.batchCreate(Array(self.contacts.selected.keys), tag: self.tag)
        
        Globals.mixpanel.track("Mobile.Invite.Shared", properties: [
            "contacts": self.contacts.selected.count,
            "users": self.users.selected.count,
            "friends": self.friends.selected.count,
            "total": count,
            "tag": self.tag.name,
            "images": self.images.count
        ])
    }
    
    func shareTriggered() {
        // Share For Users
        let users = Array(self.users.selected.keys) + Array(self.friends.selected.keys)
        
        if !users.isEmpty {
            self.tag.invite(self.user, users: users, callback: { Void in
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
        let contacts: [String] = self.contacts.selected.keys.map { (contact) -> String in
            return contact.phone.number
        }
        
        if let image = self.messageImage {
            let data =  UIImageJPEGRepresentation(image, 0.5)
            messageVC.addAttachmentData(data!, typeIdentifier: "image/jpeg", filename: "\(self.tag).jpg")
        }
        
        messageVC.recipients = contacts
        messageVC.messageComposeDelegate = self
        messageVC.body = String(format: self.config.inviteMessage, self.tag.name, self.tag.name)
        
        self.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func filterBySearch(var text: String) {
        let numberSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let alphaNumberSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let number = text.componentsSeparatedByCharactersInSet(numberSet).joinWithSeparator("")
        
        if text.isEmpty {
            self.users.filtered = Array(self.users.selected.keys)
            self.friends.filtered = self.friends.raw
            self.contacts.filtered = self.contacts.raw
        } else {
            self.friends.filtered.removeAll()
            self.contacts.filtered.removeAll()
            
            text = text.lowercaseString
                .componentsSeparatedByCharactersInSet(alphaNumberSet)
                .joinWithSeparator("")
            
            // Users
            User.find(text, callback: { (users) -> Void in
                self.users.filtered = users
                self.tableView.reloadData()
            })
            
            // Friends
            for user in self.friends.raw {
                let containsName = NSString(string: user.fullName.lowercaseString).containsString(text)
                let containsPhone = NSString(string: user.phone).containsString(number)
                let containsUsername = NSString(string: user.username!).containsString(text)
                
                if containsName || containsPhone || containsUsername {
                    self.friends.filtered.append(user)
                }
            }
            
            // Contacts
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
            
            self.friends.raw = users
            self.intersectionsUsersContacts()
            self.filterBySearch("")
            self.user.addFriends(numbers)
        }
    }
    
    func intersectionsUsersContacts() {
        var contacts: [String: Int] = [:]
        
        for (i, contact) in self.contacts.raw.enumerate() {
            contacts[contact.phone.e164] = i
        }
        
        for user in self.friends.raw {
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

    
    func collageImage(rect: CGRect, var images: [UIImage]) -> UIImage {
        if images.count == 1 {
            return images[0]
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false,  UIScreen.mainScreen().scale)
        
        let nrofColumns: Int = 2
        let nrOfRows: Int = (images.count)/nrofColumns
        let remainingPics: Int = min(0, images.count - (nrofColumns * nrOfRows))
        
        images.removeRange(Range(start: 0, end: remainingPics))
        
        let w: CGFloat = rect.width/CGFloat(nrofColumns)
        let h = rect.height/CGFloat(nrOfRows)
        var colNr = 0
        var rowNr = 0
        for var i=0; i<images.count; ++i {
            images[i].drawInRectAspectFill(CGRectMake(CGFloat(colNr)*w,CGFloat(rowNr)*h,w,h))
            
            if i == nrofColumns || ((i % nrofColumns) == 0 && i > nrofColumns) {
                ++rowNr
                colNr = 0
            } else {
                ++colNr
            }
        }
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return outputImage
    }
}
