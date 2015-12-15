//
//  ShareTableCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

let normalColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
let selectedColor = Colors.blue
let inviteImage = UIImage(named: "Invite")
let selectImage = UIImage(named: "InviteSelected")

class ShareTableCell: UITableViewCell {
    
    private var accessoryImageView = UIImageView(image: inviteImage)
    var share: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        self.textLabel?.textColor = UIColor.blackColor()
        self.textLabel?.font = UIFont(name: "Bariol", size: 20)
        self.detailTextLabel?.textColor = UIColor.lightGrayColor()
        self.detailTextLabel?.font = UIFont(name: "Bariol", size: 16)
        self.accessoryView = self.accessoryImageView
        
        self.accessoryImageView.contentMode = .ScaleAspectFit
        self.accessoryImageView.tintColor = normalColor
        self.accessoryImageView.frame.size.height = self.frame.height
        self.accessoryImageView.frame.size.width = self.frame.height
        self.accessoryImageView.frame.origin.x = self.frame.width - self.frame.height
    }
    
    func updateAccessory() {
        self.accessoryImageView.image = self.share ? selectImage : inviteImage
        self.accessoryImageView.tintColor = self.share ? selectedColor : normalColor
    }

}
