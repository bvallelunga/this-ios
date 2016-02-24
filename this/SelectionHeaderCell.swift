//
//  SelectionHeaderCell.swift
//  this
//
//  Created by Brian Vallelunga on 2/23/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

class SelectionHeaderCell: UICollectionViewCell {
    
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
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(white: 0, alpha: 1).CGColor
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.imageView)
        
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = UIImage(named: "Trash")
        imageView.tintColor = UIColor.whiteColor()
        imageView.backgroundColor = UIColor(red:0.89, green:0.39, blue:0.46, alpha:0.3)
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.addSubview(imageView)
    }
    
}
