//
//  ShareController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ShareController: UITableViewController, ShareHeaderControllerDelegate {
    
    struct Users {
        var raw: [Contact] = []
        var filtered: [Contact] = []
        var selected: [Contact: Bool] = [:]
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
    var sectionShift = 0
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
        
        self.loadContacts()
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
        self.sectionShift = self.users.filtered.isEmpty ? 1 : 0
        return 2 - self.sectionShift
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == self.sectionShift ? self.users.filtered.count : self.contacts.filtered.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == self.sectionShift ? "SUGGESTED CONTACTS" : "NOT YET ON THE APP"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "Bariol-Bold", size: 20)
        header.textLabel?.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ShareTableCell
        
        if indexPath.section == self.sectionShift {
            let user = self.users.filtered[indexPath.row]
            cell.share = self.users.selected[user] != nil
        } else {
            let contact = self.contacts.filtered[indexPath.row]
            var label = contact.phone.label
            let number = contact.phone.number
            
            if label == nil {
                label = ""
            } else {
                label = "\(label): "
            }
            
            cell.textLabel?.text = contact.name
            cell.detailTextLabel?.text = "\(label)\(number)"
            cell.share = self.contacts.selected[contact] != nil
        }
        
        cell.accessoryView?.tintColor = cell.share ? cell.selectedColor: cell.normalColor
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ShareTableCell
        
        cell.share = !cell.share
        cell.accessoryView?.tintColor = cell.share ? cell.selectedColor: cell.normalColor
        
        if indexPath.section == self.sectionShift {
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
    }
    
    func backTriggred() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func filterBySearch(var text: String) {
        if text.isEmpty {
            self.users.filtered = self.users.raw
            self.contacts.filtered = self.contacts.raw
        } else {
            self.users.filtered.removeAll()
            self.contacts.filtered.removeAll()
            
            text = text.lowercaseString
            
            for user in self.users.raw {
                let containsName = NSString(string: user.name.lowercaseString).containsString(text)
                let containsPhone = NSString(string: user.phone.number).containsString(text)
                
                if containsName || containsPhone {
                    self.users.filtered.append(user)
                }
            }
            
            for contact in self.contacts.raw {
                let containsName = NSString(string: contact.name.lowercaseString).containsString(text)
                let containsPhone = NSString(string: contact.phone.number).containsString(text)
                
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
            self.filterBySearch("")
        }
    }

}
