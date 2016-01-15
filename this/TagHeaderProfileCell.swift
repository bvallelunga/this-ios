//
//  TagHeaderProfileCollectionViewCell.swift
//  this
//
//  Created by Brian Vallelunga on 1/14/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagHeaderProfileCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
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
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderColor = Colors.darkGrey.CGColor
        self.layer.borderWidth = 1
        
        self.imageView.frame = CGRectMake(1, 1, self.bounds.width-2, self.bounds.height-2)
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = Colors.lightGrey
        self.imageView.layer.cornerRadius = self.imageView.frame.width/2

        self.addSubview(self.imageView)
    }
    
}
