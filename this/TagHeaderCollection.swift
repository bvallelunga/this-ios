//
//  TagHeaderCollection.swift
//  this
//
//  Created by Brian Vallelunga on 1/1/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class TagHeaderCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var parent: TagHeaderPages!
    var page: Int = 0
    var count: Int = 0
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        
        self.init(collectionViewLayout: layout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.scrollEnabled = false
        self.collectionView?.pagingEnabled = false
        self.collectionView?.contentInset = UIEdgeInsetsMake(15, 10, 0, 10)
        self.collectionView?.registerClass(TagCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.count
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let number = self.parent.columns
        let length = self.collectionView!.frame.size.width - 25
        let size = length/CGFloat(number) - CGFloat(2 * (number - 1))
        return CGSizeMake(size, size)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TagCollectionCell
        let index = indexPath.row + (self.parent.grid * self.page)
        let image = self.parent.images[index]
        
        cell.imageView.image = image
        cell.downloadMode(self.parent.downloadMode)
        
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionCell
        
        let index = indexPath.row + (self.parent.grid * self.page)
        
        if self.parent.downloadMode {
            self.parent.cellDownload(cell, index: index)
        } else {
            self.parent.cellGallery(cell, index: index)
        }
    }

}
