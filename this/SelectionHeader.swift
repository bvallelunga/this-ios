//
//  SelectionHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Gifu

protocol SelectionHeaderDelegate {

}

class SelectionHeader: UICollectionViewCell {
    
    @IBOutlet weak var placeholderView: AnimatableImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var delegate: SelectionHeaderDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.green
        
        self.placeholderLabel.textColor = UIColor(white: 0, alpha: 0.15)
        self.placeholderLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        self.placeholderLabel.layer.shadowOffset = CGSizeMake(0, 2)
        self.placeholderLabel.layer.shadowOpacity = 1
        self.placeholderLabel.layer.shadowRadius = 0
        
        self.placeholderView.layer.cornerRadius = 4
        self.placeholderView.clipsToBounds = true
        self.placeholderView.contentMode = .ScaleAspectFill
        self.placeholderView.animateWithImage(named: "Placeholder.gif")
    }
}
