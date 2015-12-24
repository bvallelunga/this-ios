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
    
    var hashtag: String = ""
    
    private var layout = TagCollectionLayout()
    private var downloadMode: Bool = false
    private var images: [UIImage] = [
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!
    ]
    
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
        
        self.pageControl.numberOfPages = Int(ceil(Double(self.images.count)/12))
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
            NavNotification.show("Tap Photos To Download", color: Colors.blue, duration: 1.5)
        }
    }
    
    @IBAction func inviteTriggered(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("ShareController") as! ShareController
        
        controller.delegate = self
        controller.images = self.images
        controller.hashtag = self.hashtag
        controller.backText = "CANCEL"
        
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func followingTriggered(sender: AnyObject) {
        self.followingButton.setTitle("FOLLOW", forState: .Normal)
    }
    
    func shareControllerDismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareControllerShared(count: Int, callback: () -> Void) {
        callback()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let size = self.collectionView.frame.size.width/4 - 15
        self.layout.itemSize = CGSizeMake(size, size)
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(
            (self.collectionView.contentOffset.x / CGFloat(self.collectionView.frame.size.width)) + 0.5
        )
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TagCollectionCell
        
        cell.imageView.image = self.images[indexPath.row]
        cell.downloadMode(self.downloadMode)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionCell
        let image = self.images[indexPath.row]
        
        if self.downloadMode {
            cell.downloaded()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            return
        }
        
        var photos: [GalleryPhoto] = []
        var intialPhoto: GalleryPhoto!
        
        for (i, image) in self.images.enumerate() {
            let photo = GalleryPhoto(image: image, user: "@bvallelunga", postedAt: "\(i) hrs ago", hashtag: self.hashtag)
            
            photo.indexPath = NSIndexPath(forItem: i, inSection: 0)
            
            if i == indexPath.row {
                intialPhoto = photo
            }
            
            photos.append(photo)
        }
        
        
        let controller = NYTPhotosViewController(photos: photos, initialPhoto: intialPhoto)
        
        controller.delegate = self
        controller.leftBarButtonItem.title = "Done"
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, handleActionButtonTappedForPhoto photo: NYTPhoto!) -> Bool {
        let image = photo as! GalleryPhoto
        let text = "\(image.user) pic on \(self.hashtag) is epic!"
        let controller = ShareGenerator.share(text, image: image.image)
        
        photosViewController.presentViewController(controller, animated: true, completion: nil)
        
        return true
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, referenceViewForPhoto photo: NYTPhoto!) -> UIView! {
        return self.collectionView.cellForItemAtIndexPath((photo as! GalleryPhoto).indexPath!)
    }
}

class GalleryPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    var indexPath: NSIndexPath?
    var placeholderImage: UIImage?
    var user: String = ""
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    
    init(image: UIImage?, user: String, postedAt: String, hashtag: String) {
        self.image = image
        self.user = user
        self.attributedCaptionTitle = NSAttributedString(string: user, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.attributedCaptionSummary =  NSAttributedString(string: postedAt, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        self.attributedCaptionCredit = NSAttributedString(string: hashtag, attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
        super.init()
    }
    
}