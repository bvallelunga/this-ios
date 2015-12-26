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
    private var following: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.darkGrey
        
        self.layout.minimumInteritemSpacing = 10
        self.layout.minimumLineSpacing = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.collectionView.collectionViewLayout = self.layout
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.registerClass(TagCollectionCell.self, forCellWithReuseIdentifier: "cell")
        
        self.setupButton(self.followingButton, color: Colors.blue)
        self.setupButton(self.inviteButton, color: Colors.green)
        self.downloadButton.tintColor = UIColor.whiteColor()
        self.updateFollowingButton()
        
        Config.sharedInstance { (config) -> Void in
            self.config = config
        }
    }
    
    func tagSet() {
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
        let text = self.following ? "FOLLOWING" : "FOLLOW"
        self.followingButton.setTitle(text, forState: .Normal)
    }
    
    func setupButton(button: UIButton, color: UIColor) {
        button.tintColor = UIColor.whiteColor()
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
        self.following = !self.following
        self.updateFollowingButton()
        
        if self.following {
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
        var controller: NYTPhotosViewController!
        
        for (i, photo) in self.photos.enumerate() {
            if let image = self.images[photo] {
                let galleryPhoto = GalleryPhoto(placeholder: image, user: photo.user.screenname,
                    postedAt: Globals.intervalDate(photo.createdAt!), hashtag: self.tag.hashtag)
                
                galleryPhoto.indexPath = NSIndexPath(forItem: i, inSection: 0)
                galleryPhoto.photo = photo
                
                if i == indexPath.row {
                    intialPhoto = galleryPhoto
                    
                    galleryPhoto.photo.fetchOriginal({ (image) -> Void in
                        galleryPhoto.image = image
                        controller.updateImageForPhoto(galleryPhoto)
                    })
                }
                
                galleryPhotos.append(galleryPhoto)
            }
        }
        
        
        controller = NYTPhotosViewController(photos: galleryPhotos, initialPhoto: intialPhoto)
        controller.delegate = self
        controller.leftBarButtonItem.title = "Done"
        
        self.presentViewController(controller, animated: true, completion: nil)
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
        let galleryPhoto = photo as! GalleryPhoto
        
        galleryPhoto.photo.fetchOriginal({ (image) -> Void in
            let text = String(format: self.config.photoMessage, String(galleryPhoto.user), self.tag.hashtag)
            let controller = ShareGenerator.share(text, image: galleryPhoto.image)
            
            photosViewController.presentViewController(controller, animated: true, completion: nil)
        })
        
        return true
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