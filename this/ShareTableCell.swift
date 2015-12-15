//
//  ShareTableCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ShareTableCell: UITableViewCell {
    
    var normalColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
    var selectedColor = Colors.blue
    var share: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        self.textLabel?.textColor = UIColor.blackColor()
        self.textLabel?.font = UIFont(name: "Bariol", size: 20)
        self.detailTextLabel?.textColor = UIColor.lightGrayColor()
        self.detailTextLabel?.font = UIFont(name: "Bariol", size: 16)
        self.accessoryView = UIImageView(image: UIImage(named: "Invite"))
        self.accessoryView?.contentMode = .ScaleAspectFit
        self.accessoryView?.tintColor = self.normalColor
        self.accessoryView?.frame.size.height = self.frame.height
        self.accessoryView?.frame.size.width = self.frame.height
        self.accessoryView?.frame.origin.x = self.frame.width - self.frame.height
    }

}
