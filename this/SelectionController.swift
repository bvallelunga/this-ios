//
//  SelectionController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import CSStickyHeaderFlowLayout

private let photoIdentifier = "photo"
private let cameraIdentifier = "camera"

class SelectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    ShareControllerDelegate, SelectionHeaderDelegate {
    
    var header: SelectionHeader!
    private var tag: Tag!
    private let manager = PHCachingImageManager()
    private var assets: [PHAsset] = []
    private var selected: [PHAsset: UIImage] = [:]
    private var config: Config!
    private var user = User.current()
    private var date = NSCalendar.currentCalendar()
        .dateByAddingUnit(.Day, value: -30, toDate: NSDate(), options: [])!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Controller
        self.navigationController?.navigationBarHidden = true
        self.edgesForExtendedLayout = .None
        
        // Setup Colletion View
        self.setupCollectionView()
        self.getAssests()
        
        // Core Setup
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
        
        // Application Became Active
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "applicationDidBecomeActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        Globals.selectionController = self
        Globals.mixpanel.track("Mobile.Selection")
    }
    
    func setupCollectionView() {
        let size = self.view.frame.size
        let itemSize = size.width/3 - 1
        let headerNib = UINib(nibName: "SelectionHeader", bundle: NSBundle.mainBundle())
        
        if let layout = self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 0.5))
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 0.5))
            layout.itemSize = CGSizeMake(itemSize, itemSize)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
        }
            
        self.collectionView?.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: photoIdentifier)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView?.registerNib(headerNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader,
            withReuseIdentifier: "header")
    }
    
    func reset() {
        self.selected.removeAll()
        self.collectionView?.reloadData()
        self.header.reset()
        self.tag = nil
    }
    
    func getAssests() {
        self.assetsAuthorized { (authorized) -> Void in
            guard authorized else {
                let controller = UIAlertController(title: "Photo Permissions",
                    message: "Please enable photo permissions by going to Settings > #this > Photos",
                    preferredStyle: .Alert)
                
                let button = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)!
                    UIApplication.sharedApplication().openURL(url)
                    Globals.mixpanel.track("Mobile.Selection.Settings Opened")
                })
                
                controller.addAction(button)
                self.presentViewController(controller, animated: true, completion: nil)
                Globals.mixpanel.track("Mobile.Selection.Needs Permissions")
                return
            }
            
            let options = PHFetchOptions()
            
            options.predicate = NSPredicate(format: "creationDate > %@", self.date)
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            
            let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
            
            results.enumerateObjectsUsingBlock { (object, _, _) in
                if let asset = object as? PHAsset {
                    self.assets.insert(asset, atIndex: 0)
                }
            }
            
            self.manager.startCachingImagesForAssets(self.assets,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .AspectFill,
                options: nil
            )
            
            if !self.assets.isEmpty {
                self.date = NSDate()
            }
            
            self.collectionView?.reloadData()
            Globals.mixpanel.track("Mobile.Selection.Photos.Fetched", properties: [
                "photos": self.assets.count
            ])
        }
    }
    
    func assetsAuthorized(callback: (authorized: Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(),{
                    callback(authorized: status == .Authorized)
                })
            })
        } else {
            callback(authorized: status == .Authorized)
        }
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        self.getAssests()
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let asset = self.assets[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier,
            forIndexPath: indexPath) as! SelectionPhotoCell
        let options = PHImageRequestOptions()
        
        options.deliveryMode = .Opportunistic
        
        cell.upload = self.selected[asset] != nil
        cell.layer.borderColor = Colors.green.CGColor
        cell.layer.borderWidth = cell.upload ? 5 : 0
        
        cell.tag = Int(self.manager.requestImageForAsset(asset,
            targetSize: cell.frame.size,
            contentMode: .AspectFill,
            options: options) { (result, _) in
                cell.imageView.image = result
        })

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! SelectionHeader
        
        cell.delegate = self
        self.header = cell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Toggle Library Image
        let asset = self.assets[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectionPhotoCell
        
        if !cell.upload && self.config != nil && self.selected.count >= self.config.uploadLimit {
            NavNotification.show("Isn't \(self.config.uploadLimit) photos enough?")
            return
        }
        
        cell.upload = !cell.upload
        cell.layer.borderWidth = cell.upload ? 5 : 0
        
        if cell.upload {
            self.cellSelected(asset)
            Globals.mixpanel.track("Mobile.Selection.Photo.Selected")
        } else {
            if let image = self.selected[asset] {
                self.header.images.removeObject(image)
                self.header.updateCollection()
            }
            
            self.selected.removeValueForKey(asset)
            Globals.mixpanel.track("Mobile.Selection.Photo.Deselected")
        }
    }
    
    func cellSelected(asset: PHAsset, force: Bool = false) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        
        self.manager.requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
            if let image = UIImage(data: imageData!) {
                self.header.images.insertObject(image, atIndex: 0)
                self.selected[asset] = image
                self.header.updateCollection()
                
                if force {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    func setHashtag(tag: String) {
        self.header.setHashtag(tag)
    }
    
    // MARK: ShareController Methods
    func shareControllerCancelled() {
        self.shareControllerInviteCompelete()
    }
    
    func shareControllerInviteCompelete() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            Globals.viewTag(self.tag, callback: { () -> Void in
                self.reset()
            })
        }
    }
    
    func shareControllerShared(count: Int) {
        
    }
    
    // MARK: SelectionHeader Methods
    func removeImage(image: UIImage) {
        let assets = (self.selected.filter { $0.1 == image }).map { $0.0 }
        
        if !assets.isEmpty {
            self.selected.removeValueForKey(assets[0])
        }
        
        self.collectionView.reloadData()
    }
    
    func updateTags(images: [UIImage], hashtag: String, timer: Int) {
        SVProgressHUD.show()
        Globals.mixpanel.timeEvent("Mobile.Selection.Tag.FindOrCreate")
        
        Tag.findOrCreate(hashtag) { (tag) -> Void in
            SVProgressHUD.dismiss()
            
            let controller = Globals.storyboard.instantiateViewControllerWithIdentifier("ShareController") as! ShareController
            controller.delegate = self
            controller.images = images
            controller.tag = tag
            controller.backButton = "SKIP"
            
            self.tag = tag
            self.presentViewController(controller, animated: true, completion: nil)
            
            var postImages = [UIImage: PHAsset]()
            
            for image in images {
                postImages[image] = PHAsset()
            }
            
            for (asset, image) in self.selected {
                postImages[image] = asset
            }
            
            tag.postImages(timer, user: self.user, images: postImages, callback: { () -> Void in
                Globals.mixpanel.track("Mobile.Selection.Tag.Post", properties: [
                    "tag": tag.name,
                    "timer": timer,
                    "photos": self.selected.count
                ])
            }, hasError: nil)
            
            Globals.mixpanel.track("Mobile.Selection.Tag.FindOrCreate", properties: [
                "tag": tag.name
            ])
        }
    }
}
