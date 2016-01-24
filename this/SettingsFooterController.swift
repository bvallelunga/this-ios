//
//  ProfileFooterController.swift
//  this
//
//  Created by Brian Vallelunga on 1/4/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

class SettingsFooterController: UIViewController {

    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signoutButton.backgroundColor = Colors.red
        self.signoutButton.tintColor = UIColor.whiteColor()
        self.signoutButton.layer.cornerRadius = 6
        
        self.versionLabel.text = "Version \(Globals.appVersionBuild())"
        self.versionLabel.textColor = Colors.lightGrey
    }
    
    @IBAction func signoutTriggered(sender: AnyObject) {
        let controller = UIAlertController(title: "You Sure?",
            message: "If you really have to leave, I understand. Your account will be here when you come back.", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let save = UIAlertAction(title: "Sign Out", style: .Destructive) { (action) -> Void in
            User.logOut()
        }
        
        controller.addAction(cancel)
        controller.addAction(save)
        
        self.presentViewController(controller, animated: true, completion: nil)
        Globals.mixpanel.track("Mobile.Settings.Logged Out")
    }

}
