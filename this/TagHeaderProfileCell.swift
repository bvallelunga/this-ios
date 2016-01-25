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
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderWidth = 1
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.imageView.layer.cornerRadius = self.bounds.width/2
        self.imageView.clipsToBounds = true
        
        self.label.frame = self.imageView.frame
        self.label.textColor = UIColor(white: 0, alpha: 0.5)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.1
        self.label.numberOfLines = 1
        self.label.textAlignment = .Center
        self.label.font = UIFont(name: "Bariol-Bold", size: 20)
        
        self.addSubview(self.label)
        self.addSubview(self.imageView)
    }
    
    func setCounter(count: Int) {
        self.setImage(nil)
        self.label.text = Globals.suffixNumber(count)
        self.backgroundColor = Colors.offWhite
        self.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
    }
    
    func setImage(image: UIImage!) {
        self.imageView.image = image
        
        self.clipsToBounds = image != nil
        self.backgroundColor = image == nil ? UIColor.clearColor(): Colors.lightGrey
        self.layer.borderColor = (image == nil ? UIColor.clearColor() : UIColor(white: 0, alpha: 0.5)).CGColor
    }
    
}
