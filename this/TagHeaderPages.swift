//
//  TagHeaderPages.swift
//  this
//
//  Created by Brian Vallelunga on 1/1/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class TagHeaderPages: UIPageViewController, UIPageViewControllerDataSource,
    UIPageViewControllerDelegate, NYTPhotosViewControllerDelegate {
    
    var tag: Tag!
    var images: [UIImage] = []
    var photos: [UIImage: Photo] = [:]
    var downloadMode = false
    var parent: TagHeaderController!
    var columns = 4
    var rows = 3
    var grid: Int!
    
    private var pages = 0
    private var page = 0
    private var user = User.current()
    private var photoViewer: NYTPhotosViewController!
    private var controllers: [TagHeaderCollection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grid = self.rows * self.columns
        self.dataSource = self
        self.delegate = self
        self.view.backgroundColor = Colors.darkGrey
        
        for controller in self.view.subviews {
            if let scrollView = controller as? UIScrollView {
                scrollView.scrollEnabled = true
            }
        }
    }

    func updateTag(tag: Tag) {
        self.tag = tag
        self.images.removeAll()
        self.photos.removeAll()
        self.reloadPages()
        
        self.photoViewer?.performSegueWithIdentifier("doneButtonTapped", sender: self)
        
        self.tag.photos { (photos) -> Void in
            for photo in photos {
                photo.fetchThumbnail(callback: { (image) -> Void in
                    guard self.photos[image] == nil else {
                        return
                    }
                    
                    self.images.append(image)
                    self.photos[image] = photo
                    self.reloadPages()
                })
            }
            
            Globals.mixpanel.track("Mobile.Tag.Photos.Fetched", properties: [
                "tag": self.tag.name,
                "photos": photos.count
            ])
        }
    }
    
    func reloadPages() {
        var count = self.images.count
        self.pages = Int(ceil(Double(self.images.count)/Double(self.grid)))
        
        for var i = 0; i < self.pages; i++ {
            var controller: TagHeaderCollection!
            
            if i < self.controllers.count {
                controller = self.controllers[i]
            } else {
                controller = TagHeaderCollection()
                self.controllers.append(controller)
            }
        
            controller.page = i
            controller.count = min(self.grid, count)
            controller.parent = self
            controller.collectionView?.reloadData()
            count -= controller.count
        }
        
        if !self.controllers.isEmpty {
            self.setViewControllers([
                self.controllers[self.page]
            ], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    // MARK: Page View Controller Data Source
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pages > 1 ? self.pages : 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.page
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        guard let controller = pendingViewControllers.first as? TagHeaderCollection else {
            return
        }
        
        self.page = controller.page
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? TagHeaderCollection else {
            return nil
        }
        
        guard controller.page > 0 else {
            return nil
        }
        
        return self.controllers[controller.page - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? TagHeaderCollection else {
            return nil
        }
        
        guard controller.page < (self.pages-1) else {
            return nil
        }
        
        return self.controllers[controller.page + 1]
    }
    
    // Instance Methods
    func downloadMode(download: Bool) {
        self.downloadMode = download
        self.reloadPages()
        
        if self.downloadMode {
            if !StateTracker.tagTapDownloadShown {
                NavNotification.show("Tap Photos To Download", color: Colors.blue, duration: 1.5, vibrate: false)
                StateTracker.tagTapDownloadShown = true
            }
            
            Globals.mixpanel.track("Mobile.Tag.Download Button", properties: [
                "tag": self.tag.name,
                "images": self.photos.count
            ])
        }
    }
    
    func cellDownload(cell: TagCollectionCell, index: Int) {
        cell.startDownload()
        
        let photo = self.photos[self.images[index]]!
        
        photo.fetchOriginal { (image) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            cell.finishedDownload()
        }
        
        Globals.mixpanel.track("Mobile.Tag.Photo.Downloaded", properties: [
            "tag": self.tag.name,
            "photos": self.photos.count
        ])
    }
    
    func cellGallery(cell: TagCollectionCell, index: Int) {
        var galleryPhotos: [GalleryPhoto] = []
        var intialPhoto: GalleryPhoto!
        
        for (i, image) in self.images.enumerate() {
            if let photo = self.photos[image] {
                let galleryPhoto = GalleryPhoto(placeholder: image, user: photo.from,
                    postedAt: Globals.intervalDate(photo.createdAt!), hashtag: self.tag.hashtag)
                
                galleryPhoto.indexPath = NSIndexPath(forItem: i, inSection: 0)
                galleryPhoto.photo = photo
                galleryPhotos.append(galleryPhoto)
                
                if i == index {
                    intialPhoto = galleryPhoto
                }
            }
        }
        
        self.photoViewer = NYTPhotosViewController(photos: galleryPhotos, initialPhoto: intialPhoto)
        self.photoViewer.delegate = self
        self.photoViewer.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop,
            target: self.photoViewer, action: Selector("doneButtonTapped:"))
        self.photoViewer.rightBarButtonItem = UIBarButtonItem(title: "FLAG", style: .Plain,
            target: self.photoViewer, action: Selector("actionButtonTapped:"))
        self.parent.presentViewController(self.photoViewer, animated: true, completion: nil)
        
        if intialPhoto != nil {
            self.photoViewer.delegate?.photosViewController?(self.photoViewer, didDisplayPhoto: intialPhoto,
                atIndex: UInt(intialPhoto.indexPath.row))
        }
        
        Globals.mixpanel.track("Mobile.Tag.Gallery.Opened", properties: [
            "tag": self.tag.name,
            "photos": self.photos.count
        ])
    }
    
    func flagPhoto(photo: Photo, index: Int) {
        photo.flag()
        self.removePhoto(photo, index: index)
        
        Globals.mixpanel.track("Mobile.Tag.Photo.Flagged", properties: [
            "tag": self.tag.name,
            "photos": self.photos.count
        ])
    }
    
    func deletePhoto(photo: Photo, index: Int) {
        photo.deleteInBackground()
        self.removePhoto(photo, index: index)
        
        Globals.mixpanel.track("Mobile.Tag.Photo.Deleted", properties: [
            "tag": self.tag.name,
            "photos": self.photos.count
        ])
    }
    
    func removePhoto(photo: Photo, index: Int) {
        self.tag.removeCachedPhoto(photo)
        self.images.removeAtIndex(index)
        self.reloadPages()
    }

    // Photo Gallery Methods
    func photosViewController(photosViewController: NYTPhotosViewController!, didDisplayPhoto photo: NYTPhoto!, atIndex photoIndex: UInt) {
        guard photo.image == nil else {
            return
        }
        
        let galleryPhoto = photo as! GalleryPhoto
        
        galleryPhoto.photo.fetchOriginal { (image) -> Void in
            galleryPhoto.image = image
            photosViewController.updateImageForPhoto(photo)
        }
        
        Globals.mixpanel.track("Mobile.Tag.Gallery.Photo.Viewed", properties: [
            "tag": self.tag.name,
            "photos": self.photos.count
        ])
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, handleActionButtonTappedForPhoto photo: NYTPhoto!) -> Bool {
        let controller = UIAlertController(title: "Flag Photo?",
            message: "Please confirm that this photo should be flagged.",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            let galleryPhoto = photo as? GalleryPhoto
            
            self.flagPhoto(galleryPhoto!.photo, index: galleryPhoto!.indexPath.row)
            
            photosViewController.performSelector(Selector("doneButtonTapped:"), withObject: self)
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        photosViewController.presentViewController(controller, animated: true, completion: nil)
        
        return true
    }
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController!) {
        self.photoViewer = nil
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, referenceViewForPhoto photo: NYTPhoto!) -> UIView! {
        let galleryPhoto = photo as! GalleryPhoto
        
        let page = Int(floor(Double(galleryPhoto.indexPath.row)/Double(self.grid)))
        let controller = self.controllers[page]
        let indexPath = NSIndexPath(forRow: galleryPhoto.indexPath.row % self.grid, inSection: 0)
        
        self.setViewControllers([controller], direction: .Forward, animated: false, completion: nil)
        
        return controller.collectionView?.cellForItemAtIndexPath(indexPath)
    }

}

class GalleryPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    var photo: Photo!
    var indexPath: NSIndexPath!
    var placeholderImage: UIImage?
    var user: String = ""
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    
    init(placeholder: UIImage?, user: String, postedAt: String, hashtag: String) {
        self.placeholderImage = placeholder
        self.user = user
        self.attributedCaptionTitle = NSAttributedString(string: user,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.attributedCaptionSummary =  NSAttributedString(string: postedAt,
            attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        self.attributedCaptionCredit = NSAttributedString(string: hashtag,
            attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
        super.init()
    }
    
}
