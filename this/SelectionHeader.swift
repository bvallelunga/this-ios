//
//  SelectionHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Gifu
import ActionSheetPicker_3_0
import AKPickerView_Swift

protocol SelectionHeaderDelegate {

}

struct SelectionTimer {
    var title: String!
    var timer: Int!
}

class SelectionHeader: UICollectionViewCell, AKPickerViewDataSource, AKPickerViewDelegate,
    UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var placeholderView: AnimatableImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var timerPicker: AKPickerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var arrowAnimation = CABasicAnimation(keyPath: "transform")
    private var timer: SelectionTimer!
    private var timers: [SelectionTimer] = [
        SelectionTimer(title: "5 days", timer: 5),
        SelectionTimer(title: "4 days", timer: 4),
        SelectionTimer(title: "3 days", timer: 3),
        SelectionTimer(title: "2 days", timer: 2),
        SelectionTimer(title: "1 day", timer: 1)
    ]
    
    var delegate: SelectionHeaderDelegate!
    var images: [UIImage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.green
        
        self.placeholderLabel.textColor = UIColor(white: 0, alpha: 0.15)
        self.placeholderLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        self.placeholderLabel.layer.shadowOffset = CGSizeMake(0, 2)
        self.placeholderLabel.layer.shadowOpacity = 1
        self.placeholderLabel.layer.shadowRadius = 0
        
        self.tagLabel.textColor = UIColor(white: 0, alpha: 0.4)
        self.tagLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        self.tagLabel.layer.shadowOffset = CGSizeMake(0, 1)
        self.tagLabel.layer.shadowOpacity = 1
        self.tagLabel.layer.shadowRadius = 0
        
        self.placeholderView.layer.cornerRadius = 4
        self.placeholderView.clipsToBounds = true
        self.placeholderView.contentMode = .ScaleAspectFill
        self.placeholderView.animateWithImage(named: "Placeholder.gif")
        
        self.tagField.tintColor = UIColor(white: 0, alpha: 0.25)
        self.tagField.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.tagField.layer.shadowOffset = CGSizeMake(0, 2)
        self.tagField.layer.shadowOpacity = 1
        self.tagField.layer.shadowRadius = 0
        self.tagField.font = UIFont(name: "Bariol-Bold", size: 36)
        self.tagField.addTarget(self.tagField, action: Selector("resignFirstResponder"),
            forControlEvents: .EditingDidEndOnExit)
        
        self.arrowButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.arrowButton.layer.shadowOffset = CGSizeMake(-1, 2)
        self.arrowButton.layer.shadowOpacity = 0.1
        self.arrowButton.layer.shadowRadius = 0
        self.enableArrow(false)
        
        let transform = CATransform3DMakeScale(1.1, 1.1, 1)
        
        self.arrowAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        self.arrowAnimation.toValue = NSValue(CATransform3D: transform)
        self.arrowAnimation.duration = 1.0
        self.arrowAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.arrowAnimation.autoreverses = true
        self.arrowAnimation.repeatCount = FLT_MAX
        
        self.timerPicker.delegate = self
        self.timerPicker.dataSource = self
        self.timerPicker.pickerViewStyle = .Wheel
        self.timerPicker.backgroundColor = UIColor.clearColor()
        self.timerPicker.highlightedTextColor = UIColor.whiteColor()
        self.timerPicker.textColor = UIColor(white: 1, alpha: 0.8)
        self.timerPicker.font = UIFont(name: "Bariol-Bold", size: 24)!
        self.timerPicker.highlightedFont = UIFont(name: "Bariol-Bold", size: 24)!
        self.timerPicker.interitemSpacing = 15
        self.timerPicker.selectItem(2)
        self.timerPicker.reloadData()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        self.collectionView.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: "cell")
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapper.cancelsTouchesInView = false
        self.addGestureRecognizer(tapper)
        
        self.imagesSelected([])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newAlpha = min(100, max(0, 100 - self.frame.origin.y)) / 100
        
        self.placeholderLabel.alpha = newAlpha
        self.placeholderView.alpha = newAlpha
        self.arrowButton.alpha = newAlpha
        self.timerPicker.alpha = newAlpha
        self.collectionView.alpha = newAlpha
    }
    
    @IBAction func tagChanged(sender: AnyObject) {
        if var text = self.tagField.text {
            guard !text.isEmpty else {
                return
            }
            
            if text[0] != "#" {
                text = "#" + text
            }
            
            self.tagField.text = text
        }
    }

    @IBAction func uploadTags(sender: AnyObject) {
        
    }
    
    @IBAction func goToFollowing(sender: AnyObject) {
        Globals.pagesController.setActiveChildController(2, animated: true,  direction: .Forward)
    }

    @IBAction func goToSettings(sender: AnyObject) {
        Globals.pagesController.setActiveChildController(0, animated: true,  direction: .Reverse)
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func imagesSelected(images: [UIImage]) {
        self.images = images
        self.collectionView.reloadData()
        
        self.collectionView.hidden = images.isEmpty
        self.placeholderLabel.hidden = !images.isEmpty
        self.placeholderView.hidden = !images.isEmpty
        self.enableArrow(!images.isEmpty)
        self.collectionView.flashScrollIndicators()
    }
    
    func enableArrow(enabled: Bool) {
        if enabled != self.arrowButton.enabled {
            self.arrowButton.enabled = enabled
            self.arrowButton.layer.removeAnimationForKey("scaleAnimation")
            
            if enabled {
                self.arrowButton.layer.addAnimation(self.arrowAnimation, forKey: "scaleAnimation")
            }
        }
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.timers.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.timers[item].title
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        self.timer = self.timers[item]
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.collectionView.frame.size.width/2 - 10
        return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SelectionPhotoCell
        
        cell.imageView.image = self.images[indexPath.row]
        cell.layer.cornerRadius = 4
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(white: 0, alpha: 1).CGColor
        
        return cell
    }
}
