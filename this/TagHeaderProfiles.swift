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
            for user in users {
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
        return self.users.count
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.frame.size.height
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TagHeaderProfileCell
        let user = self.users[indexPath.row]
        
        cell.setImage(self.images[user])
        
        return cell
    }

}
