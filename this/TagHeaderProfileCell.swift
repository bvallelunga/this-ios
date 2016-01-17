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
    static private var emojis = (
        "😄😃😀😊😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂" +
        "😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟" +
        "😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨" +
        "👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥"
    ).characters.map { String($0) }.shuffle()
    
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
        
        self.imageView.frame = CGRectMake(1, 1, self.bounds.width-2, self.bounds.height-2)
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.imageView.layer.cornerRadius = self.bounds.width/2
        self.imageView.clipsToBounds = true
        
        self.label.frame = self.imageView.frame
        self.label.font = UIFont.systemFontOfSize(50)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.1
        self.label.numberOfLines = 1
        self.label.textAlignment = .Center
        
        self.addSubview(self.label)
        self.addSubview(self.imageView)
    }
    
    func setImage(image: UIImage!, var index: Int) {
        self.imageView.image = image
        
        if index >= TagHeaderProfileCell.emojis.count {
            index = index - TagHeaderProfileCell.emojis.count
        }
        
        self.label.text = TagHeaderProfileCell.emojis[index]
        
        self.clipsToBounds = image != nil
        self.backgroundColor = image == nil ? UIColor.clearColor(): Colors.lightGrey
        self.layer.borderColor = (image == nil ? UIColor.clearColor() : Colors.darkGrey).CGColor
    }
    
}
