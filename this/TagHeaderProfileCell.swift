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
    ).characters.map { String($0) }
    
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
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderWidth = 1
        
        self.imageView.frame = CGRectMake(1, 1, self.bounds.width-2, self.bounds.height-2)
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.imageView.layer.cornerRadius = self.bounds.width/2
        
        self.label.frame = self.imageView.frame
        self.label.font = UIFont.systemFontOfSize(35)
        self.label.textAlignment = .Center
        self.label.text = TagHeaderProfileCell.emojis[
            Int(arc4random_uniform(UInt32(TagHeaderProfileCell.emojis.count)))
        ]
        
        self.addSubview(self.label)
        self.addSubview(self.imageView)
    }
    
    func setImage(image: UIImage!) {
        self.imageView.image = image
        
        self.backgroundColor = image == nil ? Colors.offWhite : Colors.lightGrey
        self.layer.borderColor = (image == nil ? Colors.whiteGrey : Colors.darkGrey).CGColor
    }
    
}
