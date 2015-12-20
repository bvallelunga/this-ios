//
//  TagHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagHeaderController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, ShareControllerDelegate {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var images: [UIImage] = [
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.darkGrey
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.collectionView.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: "cell")
        
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
    
    }
    
    @IBAction func inviteTriggered(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("ShareController") as! ShareController
        
        controller.delegate = self
        controller.images = self.images
        
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func followingTriggered(sender: AnyObject) {
    
    }
    
    func shareControllerDismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareControllerShared(count: Int, callback: () -> Void) {
        print(count)
        callback()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.collectionView.frame.size.width/4 - 15
        return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SelectionPhotoCell
        
        cell.imageView.image = self.images[indexPath.row]
        cell.backgroundColor = Colors.lightGrey
        cell.layer.cornerRadius = 4
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(white: 0, alpha: 1).CGColor
        
        return cell
    }
}