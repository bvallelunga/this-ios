//
//  Globals.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

class Globals: NSObject {
    
    static var landingController: LandingController!
    static var pagesController: PagesController!
    static var selectionController: SelectionController!
    static var tagsController: TagsController!
    static var profileController: ProfileController!
    
    static let infoDictionary = NSBundle.mainBundle().infoDictionary!
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func registerParseClasses() {
        User.registerSubclass()
    }
    
    class func parseCredentials() -> [String] {
        let parseApplicationID = self.infoDictionary["ParseApplicationID"] as! String
        let parseClientKey = self.infoDictionary["ParseClientKey"] as! String
        
        return [parseApplicationID, parseClientKey]
    }
    
    class func mixpanelToken() -> String {
        return self.infoDictionary["MixpanelToken"] as! String
    }
    
    class func appBuildVersion() -> String {
        let version = self.infoDictionary["CFBundleShortVersionString"] as! NSString
        let build = self.infoDictionary[String(kCFBundleVersionKey)] as! NSString
        
        return "\(version) - \(build)"
    }
    
    class func appVersion() -> String {
        return self.infoDictionary["CFBundleShortVersionString"] as! String
    }

}
