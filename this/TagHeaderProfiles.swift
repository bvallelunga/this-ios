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
    private var userCount = 0
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
            self.userCount = users.count
            
            for user in users[0...min(30, users.count-1)] {                
                user.fetchPhoto({ (image) -> Void in
                    self.users.append(user)
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
        
        cell.setImage(self.images[user])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row > 0 else {
            NavNotification.show("\(self.userCount) follower\(self.userCount != 1 ? "s": "")",
                color: Colors.lightGrey, vibrate: false, duration: 1)
            return
        }
        
        let controller = Globals.storyboard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
        controller.user = self.users[indexPath.row - 1]
        Globals.tagController.navigationController?.pushViewController(controller, animated: true)
    }

}
