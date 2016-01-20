//
//  ProfileHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/21/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ProfileHeaderController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var user = User.current()
    private var avatarBorder = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.purple
        
        // Configure Navigation Bar
        self.navigationBar.translucent = true
        self.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        
        self.avatarBorder.borderColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.avatarBorder.borderWidth = 2
        
        self.avatarButton.contentMode = .ScaleAspectFill
        self.avatarButton.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.avatarButton.tintColor = UIColor(white: 1, alpha: 0.4)
        self.avatarButton.imageView?.contentMode = .ScaleAspectFill
        self.avatarButton.layer.insertSublayer(self.avatarBorder, atIndex: 0)
        
        self.updateHeader()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.avatarBorder.frame = CGRectMake(-2, -2, self.avatarButton.frame.width + 4, self.avatarButton.frame.height + 4)
        self.avatarBorder.cornerRadius = self.avatarBorder.frame.width/2
        self.avatarButton.layer.cornerRadius = self.avatarButton.frame.width/2
        self.avatarButton.imageView?.layer.cornerRadius = self.avatarButton.frame.width/2
    }
    
    @IBAction func goToSelection(sender: AnyObject) {
        Globals.pagesController.setActiveController(1, direction: .Forward)
        Globals.mixpanel.track("Mobile.Settings.Go To Selection")
    }

    @IBAction func changeAvatar(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = ["public.image"]
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func updateHeader() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        
        self.userLabel.text = self.user.screenname
        self.nameLabel.text = "Joined \(formatter.stringFromDate(self.user.createdAt!))"
        
        self.user.fetchPhoto { (image) -> Void in
            self.avatarButton.setImage(image, forState: .Normal)
        }
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.avatarButton.setImage(image, forState: .Normal)
        self.user.uploadPhoto(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
