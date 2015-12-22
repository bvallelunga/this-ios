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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.purple
        
        // Configure Navigation Bar
        self.navigationBar.translucent = true
        self.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        
        // Remove Text From Back Button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000),
            forBarMetrics: UIBarMetrics.Default)
        
        self.avatarButton.layer.masksToBounds = true
        self.avatarButton.contentMode = .ScaleAspectFill
        self.avatarButton.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.avatarButton.tintColor = UIColor(white: 1, alpha: 0.4)
        self.avatarButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.avatarButton.layer.borderWidth = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.avatarButton.layer.cornerRadius = self.avatarButton.frame.width/2
    }
    
    @IBAction func goToSelection(sender: AnyObject) {
        Globals.pagesController.setActiveController(1, direction: .Forward)
    }

    @IBAction func changeAvatar(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = ["public.image"]
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.avatarButton.setImage(image, forState: .Normal)
        self.avatarButton.imageView?.contentMode = .ScaleAspectFill
        print(self.avatarButton)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
