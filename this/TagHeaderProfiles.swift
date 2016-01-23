//
//  TagHeaderProfiles.swift
//  this
//
//  Created by Brian Vallelunga on 1/14/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class TagHeaderProfiles: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var hashtag: Tag!
    private var users: [User] = []
    private var images: [User: UIImage] = [:]
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clearColor()
        self.contentInset = UIEdgeInsetsMake(0, 10, 0, 10)
        self.registerClass(TagHeaderProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func updateTag(tag: Tag) {
        self.hashtag = tag
        self.users.removeAll()
        self.images.removeAll()
        self.reloadData()
        
        tag.followers { (users) -> Void in
            for user in users[0...min(30, users.count-1)] {
                self.users.append(user)
                self.images[user] = nil
                self.reloadData()
                
                user.fetchPhoto({ (image) -> Void in
                    self.images[user] = image
                    self.reloadData()
                })
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !self.users.isEmpty else {
            return 0
        }
        
        return self.users.count + 1
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.frame.size.height
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TagHeaderProfileCell
        
        guard indexPath.row > 0 else {
            cell.setCounter(self.users.count)
            return cell
        }
        
        let user = self.users[indexPath.row - 1]
        
        cell.setImage(self.images[user], index: indexPath.row - 1)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var text = "\(self.users.count) followers"
        
        if indexPath.row > 0 {
            text = self.users[indexPath.row - 1].screenname
        }
        
        NavNotification.show(text, color: Colors.lightGrey, vibrate: false, duration: 1)
    }

}
