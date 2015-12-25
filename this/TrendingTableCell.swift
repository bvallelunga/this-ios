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
    private var spacer: Bool = false
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
        self.spacer = false
        self.hashtag = tag
        self.contentView.alpha = 1
        self.tagLabel.text = tag.hashtag
        self.followersLabel.text = "\(tag.followerCount)"
        self.followersLabel.hidden = false
        self.iconImage.hidden = false
        self.tagLabel.backgroundColor = UIColor.clearColor()
        self.images.removeAll()
        self.collectionView.reloadData()
        
        tag.photos(8) { (photos) -> Void in
            for photo in photos {
                photo.fetchThumbnail({ (image) -> Void in
                    self.images.append(image)
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    func makeSpacer() {
        self.spacer = true
        self.tagLabel.text = ""
        self.tagLabel.backgroundColor = Colors.lightGrey
        self.followersLabel.hidden = true
        self.iconImage.hidden = true
        self.contentView.alpha = 0.15
        self.images.removeAll()
        self.collectionView.reloadData()
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
        
        if self.spacer {
            cell.backgroundColor = Colors.tiles[indexPath.row]
        } else {
            cell.backgroundColor = Colors.lightGrey
        }
        
        if self.images.count <= indexPath.row {
            cell.imageView.image = nil
        } else {
            cell.imageView.image = self.images[indexPath.row]
        }
        
        return cell
    }

    
}
