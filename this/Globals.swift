//
//  Globals.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import AlamofireImage
import FormatterKit

class Globals: NSObject {
    
    static var landingController: LandingController!
    static var pagesController: PagesController!
    static var selectionController: SelectionController!
    static var tagsController: TagsController!
    static var profileController: ProfileController!
    static var followingController: FollowingController!
    static var trendingController: TrendingController!
    
    static let infoDictionary = NSBundle.mainBundle().infoDictionary!
    static let imageCache = AutoPurgingImageCache()
    static let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 8,
        imageCache: imageCache
    )
    
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
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        if let image = Globals.imageCache.imageForRequest(request) {
            callback(image: image)
            return
        }
        
        Globals.imageDownloader.downloadImage(URLRequest: request) { response in
            if let image: UIImage = response.result.value {
                callback(image: image)
                
                Globals.imageCache.addImage(image, forRequest: request)
            } else {
                print(response)
            }
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
        return "\(self.appVersion()) - \(self.appBuild())"
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
    
}
