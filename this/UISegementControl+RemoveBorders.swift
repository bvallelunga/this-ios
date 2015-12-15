//
//  UISegementControl+RemoveBorders.swift
//  this
//
//  Created by Brian Vallelunga on 12/15/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

import UIKit

extension UISegmentedControl {
    func removeBorders() {
        self.setBackgroundImage(self.imageWithColor(self.backgroundColor!), forState: .Normal, barMetrics: .Default)
        self.setBackgroundImage(self.imageWithColor(self.tintColor!), forState: .Selected, barMetrics: .Default)
        self.setDividerImage(self.imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}