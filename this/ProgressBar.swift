//
//  AuthProgressBar.swift
//  this
//
//  Created by Brian Vallelunga on 12/11/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class ProgressBar: UIView {

    private var percent: CGFloat = 0
    private var bar = UIView()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.bar.frame = CGRectMake(0, 0, 0, rect.height)
        
        self.addSubview(self.bar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.bar.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.bar.frame.size.width = self.frame.size.width * self.percent
    }
    
    func updatePercent(percent: CGFloat, animate: Bool) {
        self.percent = percent
        
        UIView.animateWithDuration(animate ? 0.2 : 0) { () -> Void in
            self.bar.frame.size.width = self.frame.size.width * percent
        }
    }

}
