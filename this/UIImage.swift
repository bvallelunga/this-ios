//
//  UIImage.swift
//  this
//
//  Created by Brian Vallelunga on 1/17/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit

extension UIImage {
    func drawInRectAspectFill(rect: CGRect, opacity: CGFloat = 1.0) {
        let targetSize = rect.size
        let scaledImage: UIImage
        if targetSize == CGSizeZero {
            scaledImage = self
        } else {
            let scalingFactor = targetSize.width / self.size.width > targetSize.height / self.size.height ? targetSize.width / self.size.width : targetSize.height / self.size.height
            let newSize = CGSize(width: self.size.width * scalingFactor, height: self.size.height * scalingFactor)
            UIGraphicsBeginImageContext(targetSize)
            self.drawInRect(CGRect(origin: CGPoint(x: (targetSize.width - newSize.width) / 2, y: (targetSize.height - newSize.height) / 2), size: newSize), blendMode: CGBlendMode.Normal, alpha: opacity)
            scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        scaledImage.drawInRect(rect)
    }
}