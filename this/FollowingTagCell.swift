//
//  FollowingCollectionCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

protocol FollowingTagCellDelegate {
    func tagCellTapped(tag: Tag)
}

class FollowingTagCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    
    var delegate: FollowingTagCellDelegate!
    private var currentImage: Int = 0
    private var images: [UIImage] = []
    var hashtag: Tag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.lightGrey
        
        self.tagLabel.shadowColor = UIColor(white: 0, alpha: 0.4)
        self.tagLabel.shadowOffset = CGSizeMake(0, 1)
        self.tagLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        self.imageView.contentMode = .ScaleAspectFill
        
        self.badgeLabel.textColor = UIColor.whiteColor()
        self.badgeLabel.backgroundColor = Colors.red
        self.badgeLabel.layer.borderColor = Colors.darkGrey.CGColor
        self.badgeLabel.layer.borderWidth = 1
        self.badgeLabel.layer.masksToBounds = true
        self.badgeLabel.layer.cornerRadius = self.badgeLabel.bounds.height/2
        
        let gesture = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        self.addGestureRecognizer(gesture)
        
        Globals.delay(Double(Globals.random(1, max: 4))) { () -> () in
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self,
                selector: Selector("cycleImage"), userInfo: nil, repeats: true)
        }
    }
    
    func updateTag(tag: Tag, images: [UIImage]) {
        let count = StateTracker.countTagNotification(tag)
        
        self.hashtag = tag
        self.images = images
        self.tagLabel.text = tag.hashtag
        self.imageView.image = images.first
        self.badgeLabel.hidden = count == 0
        self.badgeLabel.text = String(count)
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        self.delegate.tagCellTapped(self.hashtag)
        self.badgeLabel.hidden = true
    }
    
    func cycleImage() {
        if !self.images.isEmpty {
            if ++self.currentImage >= self.images.count {
                self.currentImage = 0
            }
            
            self.imageView.image = self.images[self.currentImage]
        }
    }
}
