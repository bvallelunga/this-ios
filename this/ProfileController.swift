//
//  ProfileController.swift
//  this
//
//  Created by Brian Vallelunga on 12/21/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ProfileController: UITableViewController {

    var headerFrame: CGRect!
    var headerController: ProfileHeaderController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerFrame = self.headerController.view.frame
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "header" {
            self.headerController = segue.destinationViewController as? ProfileHeaderController
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var delta: CGFloat = 0
        var rect = self.headerFrame
        
        if self.tableView.contentOffset.y < 0 {
            delta = fabs(min(0, self.tableView.contentOffset.y))
        }
        
        rect.origin.y -= delta
        rect.size.height += delta
        
        self.headerController.view.frame = rect
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
