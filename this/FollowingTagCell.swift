//
//  FollowingCollectionCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class FollowingTagCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    
    private var currentImage: Int = 0
    private var imageTimer: NSTimer!
    private var images: [UIImage] = [
        UIImage(named: "Sample-0")!,
        UIImage(named: "Sample-1")!,
        UIImage(named: "Sample-2")!,
        UIImage(named: "Sample-3")!
    ]
    
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
        
        // TODO: Remove when parse is added
        self.tagLabel.text = "#blackcat15"
        self.imageView.image = self.images.first
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.startCycling()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.stopCycling()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.stopCycling()
    }
    
    func cycleImage() {
        if ++self.currentImage >= self.images.count {
            self.currentImage = 0
        }
        
        self.imageView.image = self.images[self.currentImage]
    }
    
    func startCycling() {
        self.cycleImage()
        
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
