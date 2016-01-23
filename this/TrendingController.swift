//
//  FollowingController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class TrendingController: UITableViewController {
    
    var parent: TagsController!
    
    private var tags: [Tag] = []
    private var images: [Tag: [UIImage]] = [:]
    private var date: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Table
        let cellNib = UINib(nibName: "TrendingTableCell", bundle: NSBundle.mainBundle())
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: reuseIdentifier)
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.tintColor = UIColor.lightGrayColor()
        self.refreshControl?.addTarget(self, action: Selector("reloadTags"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Core Setup
        Globals.trendingController = self
        Globals.mixpanel.track("Mobile.Trending")
        
        if self.date == nil || self.tags.isEmpty || NSCalendar.currentCalendar().components(.Minute, fromDate: self.date, toDate: NSDate(), options: []).minute > 10 {
            self.reloadTags()
        }
    }
    
    func reloadTags() {
        Tag.trending { (tags) -> Void in
            self.tags = tags
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.date = NSDate()
            
            for tag in tags {
                self.images[tag] = []
                
                tag.photos(8) { (photos) -> Void in
                    for photo in photos {
                        photo.fetchThumbnail(callback: { (image) -> Void in
                            self.images[tag]?.append(image)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
            
            Globals.mixpanel.track("Mobile.Trending.Tags.Fetched", properties: [
                "tags": tags.count
            ])
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.tags.count, self.tags.isEmpty ? 2 : 0)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 238
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.tags.count > indexPath.row {
            self.parent.viewTag(self.tags[indexPath.row])
            Globals.mixpanel.timeEvent("Mobile.Trending.Tag.Selected")
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TrendingTableCell

        if self.tags.count <= indexPath.row {
            cell.makeSpacer()
        } else {
            let tag = self.tags[indexPath.row]
            cell.updateTag(tag, images: self.images[tag]!)
        }
        
        return cell
    }
}
