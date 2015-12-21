//
//  TagCollectionCell.swift
//  this
//
//  Created by Brian Vallelunga on 12/20/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagCollectionCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = Colors.darkGrey
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.backgroundColor = Colors.lightGrey
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        
        self.label.frame = self.bounds
        self.label.font = UIFont(name: "Bariol-Bold", size: 45)
        self.label.textColor = UIColor.whiteColor()
        self.label.textAlignment = .Center
        self.label.backgroundColor = Colors.blue
        self.label.text = "😃"
        self.label.alpha = 0
        
        self.addSubview(self.imageView)
        self.addSubview(self.label)
    }
    
    func downloadMode(active: Bool) {
        self.layer.borderColor =  active ? Colors.offBlue.CGColor : UIColor(white: 0, alpha: 1).CGColor
        self.label.alpha = 0
    }
    
    func downloaded() {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.label.alpha = 1
        })
        
        Globals.delay(1) { () -> () in
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.label.alpha = 0
            })
        }
    }
}
