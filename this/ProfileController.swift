//
//  ProfileController.swift
//  this
//
//  Created by Brian Vallelunga on 1/23/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit
import NYTPhotoViewer

private let reuseIdentifier = "cell"

class ProfileController: UICollectionViewController, NYTPhotosViewControllerDelegate {
    
    var user: User!
    private var photos: [Photo] = []
    private var images: [Photo: UIImage] = [:]
    private var spinner: UIActivityIndicatorView!
    private var photoViewer: NYTPhotosViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = Colors.darkGrey
        
        let size = self.view.frame.size
        let itemSize = size.width/3 - 1
        
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSizeMake(itemSize, itemSize)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        }
        
        self.collectionView?.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        // Add Spinner
        self.spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner)
        
        self.loadImages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.lockPageView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.pagesController.unlockPageView()
    }
    
    func loadImages() {
        self.spinner.startAnimating()
        
        self.user.fetchIfNeededInBackgroundWithBlock { (user, error) -> Void in
            guard error == nil else {
                return
            }
            
            self.title = self.user.screenname
        }
        
        self.user.photos { (photos) -> Void in
            self.photos = photos
            self.collectionView?.reloadData()
            self.spinner.stopAnimating()
            
            for photo in photos {
                photo.fetchThumbnail(callback: { (image) -> Void in
                    self.images[photo] = image
                    self.collectionView?.reloadData()
                })
            }
        }
    }
    
    func flagPhoto(photo: Photo, index: Int) {
        photo.flag()
        self.photos.removeAtIndex(index)
        self.collectionView?.reloadData()
        
        Globals.mixpanel.track("Mobile.Profile.Photo.Flagged")
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
            forIndexPath: indexPath) as! SelectionPhotoCell
        let photo = self.photos[indexPath.row]
        
        cell.upload = false
        cell.imageView.image = self.images[photo]
        cell.backgroundColor = Colors.lightGrey
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var galleryPhotos: [GalleryPhoto] = []
        var intialPhoto: GalleryPhoto!
        
        for (i, photo) in self.photos.enumerate() {
            if let image = self.images[photo] {
                let galleryPhoto = GalleryPhoto(placeholder: image, user: photo.from,
                    postedAt: Globals.intervalDate(photo.createdAt!), hashtag: "")
                
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
        
        Globals.mixpanel.track("Mobile.Profile.Gallery.Photo.Viewed")
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
        
        return self.collectionView?.cellForItemAtIndexPath(galleryPhoto.indexPath)
    }

}
