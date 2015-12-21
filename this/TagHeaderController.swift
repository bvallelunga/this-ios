//
//  TagHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagHeaderController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, ShareControllerDelegate {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var hashtag: String = ""
    
    private var layout = TagCollectionLayout()
    private var downloadMode: Bool = false
    private var images: [UIImage] = [
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-3")!,
        UIImage(named: "Sample-1")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.darkGrey
        
        self.layout.minimumInteritemSpacing = 20
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
            NavNotification.show("Tap Photos To Download", color: Colors.blue)
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
        
        cell.downloaded()
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}