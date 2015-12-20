//
//  SelectionHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Gifu
import AKPickerView_Swift

protocol SelectionHeaderDelegate {
    func updateTags(hashtag: String, timer: Int)
}

struct SelectionTimer {
    var title: String!
    var timer: Int!
}

class SelectionHeader: UICollectionViewCell, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var placeholderView: AnimatableImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var hashtag: String = ""
    private var arrowAnimation = CABasicAnimation(keyPath: "transform")
    private var timer: SelectionTimer!
    private var timers: [SelectionTimer] = [
        SelectionTimer(title: "1 day", timer: 1),
        SelectionTimer(title: "2 days", timer: 2),
        SelectionTimer(title: "3 days", timer: 3),
        SelectionTimer(title: "4 days", timer: 4),
        SelectionTimer(title: "5 days", timer: 5)
    ]
    
    var delegate: SelectionHeaderDelegate!
    var images: [UIImage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.green
        
        self.placeholderLabel.textColor = UIColor(white: 0, alpha: 0.15)
        self.placeholderLabel.shadowColor = UIColor.whiteColor()
        self.placeholderLabel.shadowOffset = CGSizeMake(0, 2)
        
        self.tagLabel.textColor = UIColor(white: 0, alpha: 0.4)
        self.tagLabel.shadowColor = UIColor.whiteColor()
        self.tagLabel.shadowOffset = CGSizeMake(0, 1)
        
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
        
        let transform = CATransform3DMakeScale(1.1, 1.1, 1)
        
        self.arrowAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        self.arrowAnimation.toValue = NSValue(CATransform3D: transform)
        self.arrowAnimation.duration = 1.0
        self.arrowAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.arrowAnimation.autoreverses = true
        self.arrowAnimation.repeatCount = FLT_MAX
        
        self.timerButton.contentHorizontalAlignment = .Left
        self.timerButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.timerButton.layer.shadowOffset = CGSizeMake(-1, 1)
        self.timerButton.layer.shadowOpacity = 0.1
        self.timerButton.layer.shadowRadius = 0
        self.timerImage.tintColor = UIColor.whiteColor()
        self.timerImage.layer.shadowColor = UIColor.blackColor().CGColor
        self.timerImage.layer.shadowOffset = CGSizeMake(-1, 1)
        self.timerImage.layer.shadowOpacity = 0.1
        self.timerImage.layer.shadowRadius = 0
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        self.collectionView.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: "cell")
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapper.cancelsTouchesInView = false
        self.addGestureRecognizer(tapper)
        
        self.reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newAlpha = min(100, max(0, 100 - self.frame.origin.y)) / 100
        
        self.placeholderLabel.alpha = newAlpha
        self.placeholderView.alpha = newAlpha
        self.arrowButton.alpha = newAlpha
        self.timerButton.alpha = newAlpha
        self.collectionView.alpha = newAlpha
    }
    
    @IBAction func changeTimer(sender: AnyObject) {
        let sheet = UIAlertController(title: "Auto Delete",
            message: "When should your photos auto delete?", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        for (i, timer) in self.timers.enumerate() {
            let action = UIAlertAction(title: timer.title, style: .Default) { (action) in
                self.setTimer(i)
            }
            sheet.addAction(action)
        }
        
        Globals.selectionController.presentViewController(sheet, animated: true, completion: nil)
    }
    
    @IBAction func tagChanged(sender: AnyObject) {
        if var text = self.tagField.text {
            text = text.stringByReplacingOccurrencesOfString(" ", withString: "",
                options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            if !text.isEmpty && text[0] != "#" {
                text = "#" + text
            }
            
            self.tagField.text = text
            self.hashtag = text
            self.checkArrow()
        }
    }

    @IBAction func uploadTags(sender: AnyObject) {
        self.delegate.updateTags(self.hashtag, timer: self.timer.timer)
    }
    
    @IBAction func goToFollowing(sender: AnyObject) {
        Globals.pagesController.setActiveController(2, direction: .Forward)
    }

    @IBAction func goToSettings(sender: AnyObject) {
        Globals.landingController.navigationController?.popToRootViewControllerAnimated(false)
        
        
        // TODO: Uncomment
        //Globals.pagesController.setActiveChildController(0, animated: true,
        //    direction: .Reverse, callback: nil)
    }
    
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func setHashtag(tag: String) {
        self.hashtag = tag
        self.tagField.text = tag
    }
    
    func generateHashtag() {
        self.hashtag = "#blackcat15"
        self.tagField.text = self.hashtag
    }
    
    func reset() {
        self.imagesSelected([])
        self.generateHashtag()
        self.setTimer(2)
    }
    
    func setTimer(index: Int) {
        self.timer = self.timers[index]
        self.timerButton.setTitle(self.timer.title, forState: .Normal)
    }
    
    func imagesSelected(images: [UIImage]) {
        self.images = images
        self.collectionView.reloadData()
        
        self.collectionView.hidden = images.isEmpty
        self.placeholderLabel.hidden = !images.isEmpty
        self.placeholderView.hidden = !images.isEmpty
        self.checkArrow()
        self.collectionView.flashScrollIndicators()
    }
    
    func checkArrow() {
        let enabled = !images.isEmpty && !self.hashtag.isEmpty
        
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
        let size = self.collectionView.frame.size.width/2 - 25
        return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
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
