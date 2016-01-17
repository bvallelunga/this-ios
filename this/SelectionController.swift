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

class SelectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    SelectionHeaderDelegate {
    
    private let manager = PHCachingImageManager()
    private var assets: [PHAsset] = []
    private var selected: [PHAsset: UIImage] = [:]
    private var selectedOrder: NSMutableArray = []
    private var date: NSDate!
    private var header: SelectionHeader!
    private var config: Config!
    private var user = User.current()
    
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
        
        self.header?.placeholderView?.startAnimating()
        
        Globals.selectionController = self
        Globals.mixpanel.track("Mobile.Selection")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.header?.placeholderView?.stopAnimating()
    }
    
    func setupCollectionView() {
        let size = self.view.frame.size
        let itemSize = size.width/3 - 1
        let headerNib = UINib(nibName: "SelectionHeader", bundle: NSBundle.mainBundle())
        
        if let layout = self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 2))
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 2))
            layout.itemSize = CGSizeMake(itemSize, itemSize)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
        }
            
        self.collectionView?.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: photoIdentifier)
        self.collectionView?.registerClass(SelectionCameraCell.self, forCellWithReuseIdentifier: cameraIdentifier)
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView?.registerNib(headerNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader,
            withReuseIdentifier: "header")
    }
    
    func reset() {
        self.selected.removeAll()
        self.selectedOrder.removeAllObjects()
        self.collectionView?.reloadData()
        self.header.reset()
    }
    
    func getAssests(select: Bool = false) {
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
            
            if self.date != nil {
                options.predicate = NSPredicate(format: "creationDate > %@", self.date)
            }
            
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            
            let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
            
            results.enumerateObjectsUsingBlock { (object, _, _) in
                if let asset = object as? PHAsset {
                    self.assets.insert(asset, atIndex: 0)
                    
                    if select {
                        self.cellSelected(asset, force: true)
                    }
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
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row > 0 {
            let asset = self.assets[indexPath.row-1]
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cameraIdentifier,
            forIndexPath: indexPath) as! SelectionCameraCell
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! SelectionHeader
        
        cell.delegate = self
        self.header = cell
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Show Camera
        if indexPath.row == 0 {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = ["public.image"]
            self.presentViewController(imagePicker, animated: true, completion: nil)
            Globals.mixpanel.track("Mobile.Selection.Camera.Shown")
            return
        }
        
        
        // Toggle Library Image
        let asset = self.assets[indexPath.row-1]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectionPhotoCell
        
        if !cell.upload && self.config != nil && self.selectedOrder.count >= self.config.uploadLimit {
            NavNotification.show("Isn't \(self.config.uploadLimit) photos enough?")
            return
        }
        
        cell.upload = !cell.upload
        cell.layer.borderWidth = cell.upload ? 5 : 0
        
        if cell.upload {
            self.cellSelected(asset)
            Globals.mixpanel.track("Mobile.Selection.Photo.Selected")
        } else  {
            self.selectedOrder.removeObject(asset)
            self.selected.removeValueForKey(asset)
            self.updateHeader()
            Globals.mixpanel.track("Mobile.Selection.Photo.Deselected")
        }
    }
    
    func cellSelected(asset: PHAsset, force: Bool = false) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        
        self.manager.requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
            if let image = UIImage(data: imageData!) {
                self.selectedOrder.insertObject(asset, atIndex: 0)
                self.selected[asset] = image
                self.updateHeader()
                
                if force {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    func setHashtag(tag: String) {
        self.header.setHashtag(tag)
    }
    
    func updateHeader() {
        var images: [UIImage] = []
        
        for asset in self.selectedOrder {
            images.append(self.selected[asset as! PHAsset]!)
        }
        
        self.header.imagesSelected(images)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        self.getAssests(true)
    }
    
    // MARK: SelectionHeader Methods
    func updateTags(hashtag: String, timer: Int) {
        SVProgressHUD.show()
        Globals.mixpanel.timeEvent("Mobile.Selection.Tag.FindOrCreate")
        
        Tag.findOrCreate(hashtag) { (tag) -> Void in
            Globals.mixpanel.track("Mobile.Selection.Tag.FindOrCreate", properties: [
                "tag": tag.name
            ])
            
            tag.postImages(timer, user: self.user, images: Array(self.selected.values), callback: { () -> Void in
                SVProgressHUD.dismiss()
                
                Globals.viewTag(tag, callback: { () -> Void in
                    self.reset()
                })
                
                Globals.mixpanel.track("Mobile.Selection.Tag.Post", properties: [
                    "tag": tag.name,
                    "timer": timer,
                    "photos": self.selected.count
                ])
            }, hasError: { () -> Void in
                SVProgressHUD.dismiss()
            })
        }
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        self.imagePickerControllerDidCancel(picker)
        Globals.mixpanel.track("Mobile.Selection.Camera.Photo Taken")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            let cell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! SelectionCameraCell
            cell.activateCamera()
        }
    }

}
