//
//  ProfileController.swift
//  this
//
//  Created by Brian Vallelunga on 12/21/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Social
import JSQWebViewController

class ProfileController: UITableViewController {

    private var headerFrame: CGRect!
    private var headerController: ProfileHeaderController!
    private var user = User.current()
    private var config: Config!
    
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Globals.profileController = self
        
        self.edgesForExtendedLayout = .None
        self.navigationController?.navigationBarHidden = true
        self.tableView.backgroundColor = Colors.offWhite
        self.tableView.separatorColor = Colors.whiteGrey
        
        self.signoutButton.backgroundColor = Colors.red
        self.signoutButton.tintColor = UIColor.whiteColor()
        self.signoutButton.layer.cornerRadius = 6
        
        self.nameLabel.text = self.user.fullName
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerFrame = self.headerController.view.frame
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "header" {
            self.headerController = segue.destinationViewController as? ProfileHeaderController
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.updateName()
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.FAQs()
            } else if indexPath.row == 1 {
                self.privacyPolicy()
            } else if indexPath.row == 2 {
                self.termsOfService()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.shareFacebook()
            } else if indexPath.row == 1 {
                self.shareTwitter()
            } else if indexPath.row == 2 {
                self.rateApp()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func signoutTriggered(sender: AnyObject) {
        let controller = UIAlertController(title: "You Sure?", message: nil, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let save = UIAlertAction(title: "Sign Out", style: .Destructive) { (action) -> Void in
            User.logOut()
        }
        
        controller.addAction(cancel)
        controller.addAction(save)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func updateName() {
        let controller = UIAlertController(title: "Gotta Name?", message: nil, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        let save = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            if let name = controller.textFields?.first?.text {
                self.nameLabel.text = name
                self.user.fullName = name
                self.user.saveInBackground()
                
                self.headerController.updateHeader()
                self.tableView.reloadData()
            }
        }
        
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .Words
            textField.text = self.user.fullName
        }
        
        controller.addAction(cancel)
        controller.addAction(save)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func rateApp() {
        let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(self.config.itunesId)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func shareFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let sheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            sheet.setInitialText(self.config.facebookMessage)
            sheet.addImage(UIImage(named: "Sample-0"))
            
            self.presentViewController(sheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let sheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            sheet.setInitialText(self.config.twitterMessage)
            sheet.addImage(UIImage(named: "Sample-0"))
            
            self.presentViewController(sheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func FAQs() {
        let url = NSURL(string: self.config.faqsURL)
        self.presentBrowser(url!)
    }
    
    func privacyPolicy() {
        let url = NSURL(string: self.config.privacyURL)
        self.presentBrowser(url!)
    }
    
    func termsOfService() {
        let url = NSURL(string: self.config.termsURL)
        self.presentBrowser(url!)
    }
    
    func presentBrowser(url: NSURL) {
        let controller = WebViewController(url: url)
        let nav = UINavigationController(rootViewController: controller)
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
}
