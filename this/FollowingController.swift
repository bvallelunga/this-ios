//
//  FollowingController.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

private let tagIdentifier = "tag"
private let spacerIdentifier = "spacer"

class FollowingController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FollowingTagCellDelegate {
    
    private var tags = [1]
    var parent: TagsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Background
        self.view.backgroundColor = UIColor.clearColor()
        self.collectionView?.backgroundColor = UIColor.clearColor()

        // Register cell classes
        let tagCell = UINib(nibName: "FollowingTagCell", bundle: NSBundle.mainBundle())
        let spacerCell = UINib(nibName: "FollowingSpacerCell", bundle: NSBundle.mainBundle())
        
        self.collectionView?.registerNib(tagCell, forCellWithReuseIdentifier: tagIdentifier)
        self.collectionView?.registerNib(spacerCell, forCellWithReuseIdentifier: spacerIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(tags.count, 6)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        if tags.count <= indexPath.row {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(spacerIdentifier, forIndexPath: indexPath) as! FollowingSpacerCell
            cell.backgroundColor = Colors.tiles[indexPath.row]
            cell.alpha = 0.15
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tagIdentifier, forIndexPath: indexPath) as! FollowingTagCell
        
        cell.alpha = 1
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.view.frame.size
        return CGSizeMake(size.width/2 - 0.5, size.height/3 - 1)
    }
    
    func tagCellTapped() {
        self.parent.performSegueWithIdentifier("next", sender: self)
    }

}
