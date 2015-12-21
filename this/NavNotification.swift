//
//  NavNotification.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import CWStatusBarNotification
import AudioToolbox

class NavNotification: NSObject {
    
    class func show(text: String, duration: NSTimeInterval = 3, color: UIColor = Colors.red, callback: (() -> Void)! = nil) {
        let notification = CWStatusBarNotification()
        
        notification.notificationAnimationInStyle = .Top
        notification.notificationAnimationOutStyle = .Top
        notification.notificationAnimationType = .Overlay
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationLabelBackgroundColor = color
        notification.notificationLabelTextColor = UIColor.whiteColor()
        notification.notificationLabelFont = UIFont(name: "Bariol-Bold", size: 32)
        notification.notificationTappedBlock = {
            notification.dismissNotification()
            callback?()
        }
        
        AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
        notification.displayNotificationWithMessage(text, forDuration: duration)
    }
    
}