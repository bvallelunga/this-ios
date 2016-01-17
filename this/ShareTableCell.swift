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
    
    private var photoView: TagHeaderProfileCell!
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
        self.imageView
        
        self.accessoryImageView.contentMode = .ScaleAspectFit
        self.accessoryImageView.tintColor = normalColor
        self.accessoryImageView.frame.size.height = self.frame.height
        self.accessoryImageView.frame.size.width = self.frame.height
        self.accessoryImageView.frame.origin.x = self.frame.width - self.frame.height
        
        let frame = CGRectMake(10, 17.5, 35, 35)
        self.photoView = TagHeaderProfileCell(frame: frame)
        self.photoView.hidden = true
        self.addSubview(self.photoView)
    }
    
    func updateAccessory() {
        self.accessoryImageView.image = self.share ? selectImage : inviteImage
        self.accessoryImageView.tintColor = self.share ? selectedColor : normalColor
    }
    
    func updateUser(user: User!, index: Int) {
        guard user != nil else {
            self.layoutMargins = UIEdgeInsetsZero
            self.photoView.hidden = true
            return
        }
        
        self.layoutMargins = UIEdgeInsetsMake(0, 55, 0, 0)
        self.photoView.hidden = false
        
        guard user.photo.url != nil else {
            self.photoView.setImage(nil, index: index)
            return
        }
        
        user.fetchPhoto { (image) -> Void in
            self.photoView.setImage(image, index: index)
        }
    }

}
