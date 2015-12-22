//
//  ProfileController.swift
//  this
//
//  Created by Brian Vallelunga on 12/21/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ProfileController: UITableViewController {

    var headerFrame: CGRect!
    var headerController: ProfileHeaderController!
    
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        self.navigationController?.navigationBarHidden = true
        self.tableView.backgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1)
        self.tableView.separatorColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1)
        
        self.signoutButton.backgroundColor = Colors.red
        self.signoutButton.tintColor = UIColor.whiteColor()
        self.signoutButton.layer.cornerRadius = 6
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
        } else if indexPath.row == 0 {
            self.FAQs()
        } else if indexPath.row == 1 {
            self.privacyPolicy()
        } else if indexPath.row == 2 {
            self.termsOfService()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    @IBAction func signoutTriggered(sender: AnyObject) {
        let controller = UIAlertController(title: "You Sure?", message: nil, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let save = UIAlertAction(title: "Sign Out", style: .Destructive) { (action) -> Void in
            Globals.landingController.navigationController?.popToRootViewControllerAnimated(false)
        }
        
        controller.addAction(cancel)
        controller.addAction(save)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func updateName() {
        let controller = UIAlertController(title: "Gotta Name?", message: nil, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        let save = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            let name = controller.textFields?.first?.text
            
            self.nameLabel.text = name
        }
        
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
        }
        
        controller.addAction(cancel)
        controller.addAction(save)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func FAQs() {
    
    }
    
    func privacyPolicy() {
    
    }
    
    func termsOfService() {
    
    }
}
