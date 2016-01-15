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
    
    private var tags: [Tag] = []
    private var refreshControl: UIRefreshControl!
    private var user = User.current()
    private var date: NSDate!
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
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGrayColor()
        self.refreshControl.addTarget(self, action: Selector("reloadTags"), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.insertSubview(self.refreshControl, atIndex: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Core Setup
        Globals.followingController = self
        Globals.mixpanel.track("Mobile.Following")
        
        if self.date == nil || self.tags.isEmpty || NSCalendar.currentCalendar().components(.Minute, fromDate: self.date, toDate: NSDate(), options: []).minute > 1 {
            self.reloadTags()
        }
    }
    
    func reloadTags() {
        self.user.following { (tags) -> Void in
            self.tags = tags
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
            self.date = NSDate()
            
            Globals.mixpanel.people.set("Following", to: tags.count)
            
            Globals.mixpanel.track("Mobile.Following.Tags.Fetched", properties: [
                "tags": tags.count
            ])
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(self.tags.count, self.tags.isEmpty ? 0 : 6)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        if self.tags.count <= indexPath.row {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(spacerIdentifier, forIndexPath: indexPath) as! FollowingSpacerCell
            
            cell.backgroundColor = Colors.lightGrey
            cell.alpha = 0.2
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tagIdentifier, forIndexPath: indexPath) as! FollowingTagCell
        
        cell.alpha = 1
        cell.delegate = self
        cell.updateTag(self.tags[indexPath.row])
        
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
    
    func tagCellTapped(tag: Tag) {
        self.parent.viewTag(tag)
        Globals.mixpanel.timeEvent("Mobile.Following.Tag.Selected")
    }

}
