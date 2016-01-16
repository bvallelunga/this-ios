//
//  Globals.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import FormatterKit
import Mixpanel
import JMImageCache
import JSQWebViewController

class Globals: NSObject {
    
    static var landingController: LandingController!
    static var pagesController: PagesController!
    static var selectionController: SelectionController!
    static var tagsController: TagsController!
    static var tagController: TagController!
    static var profileController: ProfileController!
    static var followingController: FollowingController!
    static var trendingController: TrendingController!
    
    static let mixpanel = Mixpanel.sharedInstance()
    static let infoDictionary = NSBundle.mainBundle().infoDictionary!
    static let imageDownloader = JMImageCache.sharedCache()
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func intervalDate(date: NSDate) -> String {
        let timeInterval = TTTTimeIntervalFormatter()
        let interval = NSDate().timeIntervalSinceDate(date)
        return timeInterval.stringForTimeInterval(-interval)
    }
    
    class func fetchImage(url: String, callback: (image: UIImage) -> Void) {
        Globals.mixpanel.timeEvent("Mobile.Fetch Photo")
        
        self.imageDownloader.imageForURL(NSURL(string: url)) { (image) -> Void in
            callback(image: image)
            Globals.mixpanel.track("Mobile.Fetch Photo")
        }
    }
    
    class func parseCredentials() -> [String] {
        let parseApplicationID = self.infoDictionary["ParseApplicationID"] as! String
        let parseClientKey = self.infoDictionary["ParseClientKey"] as! String
        
        return [parseApplicationID, parseClientKey]
    }
    
    class func mixpanelToken() -> String {
        return self.infoDictionary["MixpanelToken"] as! String
    }
    
    class func appVersionBuild() -> String {
        return "\(self.appVersion()) (\(self.appBuild()))"
    }
    
    class func appBuild() -> String {
        return self.infoDictionary[String(kCFBundleVersionKey)] as! String
    }
    
    class func appVersion() -> String {
        return self.infoDictionary["CFBundleShortVersionString"] as! String
    }
    
    class func random(digits: Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(min...max)
    }
    
    class func viewTag(tag: Tag, animated: Bool = true, callback: (() -> Void)! = nil) {
        self.pagesController?.setActiveController(2, animated: animated, direction: .Forward) { () -> Void in
            Globals.delay(0.25, closure: { () -> () in
                if self.tagController != nil {
                    self.tagController.updateTag(tag)
                } else if self.tagsController != nil {
                    self.tagsController.viewTag(tag)
                } else {
                    self.viewTag(tag, animated: animated, callback: callback)
                    return
                }
                
                callback?()
            })
        }
    }
    
    class func commentsTag(tag: Tag) {
        guard let controller = Globals.tagController else {
            return
        }

        if controller.tag.objectId == tag.objectId {
            controller.updateComments()
        }
    }
    
    class func presentBrowser(url: NSURL, title: String, sender: UIViewController) {
        let controller = WebViewController(url: url)
        let nav = UINavigationController(rootViewController: controller)
        
        // Configure Controller
        controller.displaysWebViewTitle = false
        controller.progressBar.tintColor = Colors.blue
        controller.webView.backgroundColor = UIColor.whiteColor()
        controller.navigationItem.rightBarButtonItem = nil
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Stop,
            target: controller,
            action: Selector("didTapDoneButton:"))
        
        // Create Text Shadow
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.1)
        shadow.shadowOffset = CGSizeMake(0, 1);
        
        // Add Bottom Border To Nav Bar
        if let frame = controller.navigationController?.navigationBar.frame {
            let navBorder = UIView(frame: CGRectMake(0, frame.height-1, frame.width, 1))
            navBorder.backgroundColor = UIColor(white: 0, alpha: 0.2)
            nav.navigationBar.addSubview(navBorder)
        }
        
        // Set Colors & Fonts
        nav.navigationBar.tintColor = UIColor.whiteColor()
        nav.navigationBar.barTintColor = Colors.lightGrey
        nav.navigationBar.barStyle = .Black
        nav.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 26)!,
            NSShadowAttributeName: shadow
        ]
        
        sender.presentViewController(nav, animated: true, completion: nil)
        controller.title = title
    }
    
}
