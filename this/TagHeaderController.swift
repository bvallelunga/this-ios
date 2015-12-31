//
//  TagHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class TagHeaderController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, ShareControllerDelegate, NYTPhotosViewControllerDelegate {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tag: Tag!
    
    private var config: Config!
    private var layout = TagCollectionLayout()
    private var downloadMode: Bool = false
    private var photos: [Photo] = []
    private var images: [Photo: UIImage] = [:]
    private var user = User.current()
    private var following: Bool!
    private var photoViewer: NYTPhotosViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.darkGrey
        
        self.layout.minimumInteritemSpacing = 10
        self.layout.minimumLineSpacing = 10
        self.layout.nbColumns = 4
        self.layout.nbLines = 3
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.collectionView.collectionViewLayout = self.layout
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.registerClass(TagCollectionCell.self, forCellWithReuseIdentifier: "cell")
        
        self.setupButton(self.followingButton, color: Colors.lightGrey)
        self.setupButton(self.inviteButton, color: Colors.green)
        self.inviteButton.tintColor = UIColor.whiteColor()
        self.downloadButton.tintColor = UIColor.whiteColor()
        self.updateFollowingButton()
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
    }
    
    func updateTag(tag: Tag) {
        self.tag = tag
        self.images.removeAll()
        self.photos.removeAll()
        self.collectionView.reloadData()
        
        self.photoViewer?.performSelector(Selector("doneButtonTapped:"), withObject: self)
        
        self.tag.photos { (photos) -> Void in
            self.photos = photos
            
            for photo in photos {
                photo.fetchThumbnail({ (image) -> Void in
                    self.images[photo] = image
                    self.collectionView.reloadData()
                })
            }
        }
        
        self.tag.isUserFollowing(self.user) { (following) -> Void in
            self.following = following
            self.updateFollowingButton()
        }
    }
    
    func updateFollowingButton() {
        guard let following = self.following else {
            self.followingButton.setTitle("LOADING", forState: .Normal)
            self.followingButton.tintColor = Colors.darkGrey
            self.followingButton.backgroundColor = Colors.lightGrey
            
            return
        }
        
        let text = following ? "FOLLOWING" : "FOLLOW"
        self.followingButton.tintColor = UIColor.whiteColor()
        self.followingButton.backgroundColor = Colors.blue
        self.followingButton.setTitle(text, forState: .Normal)
    }
    
    func setupButton(button: UIButton, color: UIColor) {
        button.backgroundColor = color
        button.layer.cornerRadius = 3
    }

    @IBAction func downloadTriggered(sender: AnyObject) {
        self.downloadMode = !self.downloadMode
        self.downloadButton.tintColor = self.downloadMode ? Colors.blue : UIColor.whiteColor()
        self.collectionView.reloadData()
        
        if self.downloadMode {
            NavNotification.show("Tap Photos To Download", color: Colors.blue, duration: 1.5, vibrate: false)
        }
    }
    
    @IBAction func inviteTriggered(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("ShareController") as! ShareController
        
        controller.delegate = self
        controller.images = Array(self.images.values)
        controller.tag = self.tag
        controller.backButton = "CANCEL"
        
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func followingTriggered(sender: AnyObject) {
        guard var following = self.following else {
            return
        }
        
        following = !following
        
        if following {
            self.tag.followers.addObject(self.user)
        } else {
            self.tag.followers.removeObject(self.user)
        }
        
        self.tag.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                Globals.followingController.reloadTags()
            } else {
                ErrorHandler.handleParse(error)
            }
        }
        
        self.following = following
        self.updateFollowingButton()
    }
    
    func shareControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareControllerShared(count: Int) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let size = self.collectionView.frame.size.width/4 - 15
        self.layout.itemSize = CGSizeMake(size, size)
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = Int(ceil(Double(self.images.count)/12))
        
        return self.images.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(
            (self.collectionView.contentOffset.x / CGFloat(self.collectionView.frame.size.width)) + 0.5
        )
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TagCollectionCell
        let photo = self.photos[indexPath.row]
        let image = self.images[photo]
        
        cell.imageView.image = image
        cell.downloadMode(self.downloadMode)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionCell
        
        if self.downloadMode {
            cell.startDownload()
            
            let photo = self.photos[indexPath.row]
            
            photo.fetchOriginal({ (image) -> Void in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                cell.finishedDownload()
            })
            
            return
        }
        
        var galleryPhotos: [GalleryPhoto] = []
        var intialPhoto: GalleryPhoto!
        
        for (i, photo) in self.photos.enumerate() {
            if let thumbnail = self.images[photo] {
                let galleryPhoto = GalleryPhoto(placeholder: thumbnail, user: photo.from,
                    postedAt: Globals.intervalDate(photo.createdAt!), hashtag: self.tag.hashtag)
                
                galleryPhoto.indexPath = NSIndexPath(forItem: i, inSection: 0)
                galleryPhoto.photo = photo
                galleryPhotos.append(galleryPhoto)
                
                if i == indexPath.row {
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
        self.presentViewController(self.photoViewer, animated: true, completion: nil)
        
        if intialPhoto != nil {
            self.photoViewer.delegate?.photosViewController?(self.photoViewer, didDisplayPhoto: intialPhoto,
                atIndex: UInt(intialPhoto.indexPath.row))
        }
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, didDisplayPhoto photo: NYTPhoto!, atIndex photoIndex: UInt) {
        guard photo.image == nil else {
            return
        }
            
        let galleryPhoto = photo as! GalleryPhoto
        
        galleryPhoto.photo.fetchOriginal({ (image) -> Void in
            galleryPhoto.image = image
            photosViewController.updateImageForPhoto(photo)
        })
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, handleActionButtonTappedForPhoto photo: NYTPhoto!) -> Bool {
        let controller = UIAlertController(title: "Flag Photo",
            message: "Please confirm that this photo violates our community guidelines?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            let galleryPhoto = photo as? GalleryPhoto
            
            galleryPhoto!.photo.flag()
            
            self.tag.removeCachedPhoto(galleryPhoto!.photo)
            self.images.removeValueForKey(galleryPhoto!.photo)
            self.collectionView.reloadData()
            Globals.followingController.reloadTags()
            
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
        return self.collectionView.cellForItemAtIndexPath((photo as! GalleryPhoto).indexPath)
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