//
//  SelectionPhoto.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class SelectionPhotoCell: UICollectionViewCell {
    
    var upload: Bool = false
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
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.imageView)
    }
}
