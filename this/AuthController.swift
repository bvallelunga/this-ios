//
//  AuthController.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class AuthController: UIViewController {

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var progressBarBottom: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bigButton: UIButton!
    
    var phoneNumber = ""
    var phoneVerify = ""
    var notifications = Notifications()
    
    private var stepIndex: Int = 0
    private var step: AuthStep!
    private var steps: [AuthStep]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stepLabel.textColor = UIColor(white: 0, alpha: 0.5)
        self.headerLabel.textColor = UIColor.whiteColor()

        self.textField.tintColor = UIColor(white: 0, alpha: 0.25)
        self.textField.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.textField.layer.shadowOffset = CGSizeMake(0, 2)
        self.textField.layer.shadowOpacity = 1
        self.textField.layer.shadowRadius = 0
        self.textField.font = UIFont(name: "Bariol-Bold", size: 40)
        
        self.bigButton.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.bigButton.tintColor = UIColor.whiteColor()
        self.bigButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.bigButton.layer.shadowOffset = CGSizeMake(0, 3)
        self.bigButton.layer.shadowRadius = 3
        self.bigButton.layer.shadowOpacity = 0.3
        self.bigButton.layer.cornerRadius = 38
        
        self.steps = [
            AuthStepPhone(parent: self),
            AuthStepVerify(parent: self),
            AuthStepUsername(parent: self),
            AuthStepNotifications(parent: self)
        ]
        
        self.step = self.steps[self.stepIndex]
        self.loadStep()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"),
            name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardDidHide:"),
            name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Unregister for keyboard notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        
        self.progressBarBottom.constant = rect.size.height
        self.view.layoutIfNeeded()
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.progressBarBottom.constant = 0
        self.view.layoutIfNeeded()
    }

    @IBAction func backTriggered(sender: AnyObject) {
        if --self.stepIndex > -1 {
            self.step = self.steps[self.stepIndex]
            self.loadStep()
        }
    }
    
    @IBAction func nextTriggered(sender: AnyObject) {        
        self.step.next { (segue, skip) -> Void in
            if segue {
                self.performSegueWithIdentifier("next", sender: self)
            } else {
                self.nextStep(skip)
            }
        }
    }
    
    @IBAction func bigButtonTriggered(sender: AnyObject) {
        self.step.button { (segue, skip) -> Void in
            if segue {
                self.performSegueWithIdentifier("next", sender: self)
            } else {
                self.nextStep(skip)
            }
        }
    }
    
    @IBAction func textFieldChanged(sender: AnyObject) {
        if let text = self.textField.text {
            self.textField.text = self.step.formatValue(text)
            self.nextButton.enabled = self.step.isValid(self.step.value)
            self.nextButton.alpha = self.nextButton.enabled ? 1 : 0.5;
        }
    }
    
    func nextStep(skip: Bool) {
        self.stepIndex += skip ? 2 : 1
        
        if self.stepIndex < self.steps.count {
            self.step = self.steps[self.stepIndex]
            self.loadStep()
        }
    }
    
    func loadStep() {
        self.stepLabel.text = self.step.title
        self.headerLabel.text = self.step.header
        self.textField.placeholder = self.step.placeholder
        self.textField.text = self.step.formatValue(self.step.value)
        self.textField.keyboardType = self.step.keyboard
        self.textField.hidden = !self.step.input
        self.textField.reloadInputViews()
        self.backButton.hidden = !self.step.showBack
        self.nextButton.setTitle(self.step.nextText, forState: .Normal)
        self.nextButton.enabled = self.step.isValid(self.step.value)
        self.nextButton.alpha = self.nextButton.enabled ? 1 : 0.5;
        self.bigButton.hidden = self.step.input
        self.bigButton.setTitle(self.step.bigText, forState: .Normal)
        
        self.progressBar.updatePercent(self.step.percent, animate: true)
        
        if self.step.input {
            self.textField.becomeFirstResponder()
        } else {
            self.textField.resignFirstResponder()
        }
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.backgroundColor = self.step.background
        }
    }
}
