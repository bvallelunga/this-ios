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
        
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self,
            selector: Selector("cycleImage"), userInfo: nil, repeats: true)
    }
    
    func updateTag(tag: Tag, images: [UIImage]) {
        self.hashtag = tag
        self.images = images
        self.tagLabel.text = tag.hashtag
        self.imageView.image = images.first
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
