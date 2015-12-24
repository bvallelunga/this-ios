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
    private var imageTimer: NSTimer!
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
    }
    
    func updateTag(tag: Tag) {
        self.hashtag = tag
        self.tagLabel.text = "#\(tag.name)"
        //self.imageView.image = tag.images
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        self.delegate.tagCellTapped(self.hashtag)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.startCycling()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        self.stopCycling()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        self.stopCycling()
    }
    
    func cycleImage() {
        if ++self.currentImage >= self.images.count {
            self.currentImage = 0
        }
        
        self.imageView.image = self.images[self.currentImage]
    }
    
    func startCycling() {
        self.tagLabel.alpha = 0
        self.badgeLabel.alpha = 0
        
        self.imageTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self,
            selector: Selector("cycleImage"), userInfo: nil, repeats: true)
    }
    
    func stopCycling() {
        if self.imageTimer != nil {
            self.imageTimer.invalidate()
            self.imageTimer = nil
        }
        
        self.tagLabel.alpha = 1
        self.badgeLabel.alpha = 1
    }
}
