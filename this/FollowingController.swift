//
//  FollowingController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class FollowingController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Table
        let cellNib = UINib(nibName: "FollowingTableCell", bundle: NSBundle.mainBundle())
        self.tableView.backgroundColor = Colors.darkGrey
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = Colors.darkGrey
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        return cell
    }
}
