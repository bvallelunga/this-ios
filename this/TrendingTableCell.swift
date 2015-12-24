//
//  FollowingTableCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TrendingTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    private var layout: UICollectionViewFlowLayout!
    private var images: [UIImage] = []
    var hashtag: Tag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        self.selectionStyle = .None
        self.backgroundColor = Colors.darkGrey
        self.iconImage.tintColor = UIColor(white: 1, alpha: 0.5)
        self.arrowImage.tintColor = UIColor(white: 0, alpha: 0.5)
        self.followersLabel.textColor = UIColor(white: 1, alpha: 0.5)
        
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerClass(TrendingCollectionCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        self.layout.minimumInteritemSpacing = 1
        self.layout.minimumLineSpacing = 1
    }
    
    func updateTag(tag: Tag) {
        self.hashtag = tag
        self.contentView.alpha = 1
    }
    
    func makeSpacer() {
        self.tagLabel.text = ""
        self.tagLabel.backgroundColor = Colors.lightGrey
        self.followersLabel.hidden = true
        self.iconImage.hidden = true
        self.contentView.alpha = 0.15
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let size = self.collectionView.bounds.width/4 - 1
        self.layout.itemSize = CGSizeMake(size, size)
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TrendingCollectionCell
        
        cell.backgroundColor = Colors.lightGrey
        
        if self.images.count <= indexPath.row {
            cell.imageView.image = nil
            cell.imageView.backgroundColor = Colors.tiles[indexPath.row]
        } else {
            cell.imageView.image = self.images[indexPath.row]
        }
        
        return cell
    }

    
}
