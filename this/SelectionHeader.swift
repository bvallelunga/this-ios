//
//  SelectionHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import FLAnimatedImage
import TagListView
import LLSimpleCamera

protocol SelectionHeaderDelegate {
    func updateTags(images: [UIImage], hashtag: String, timer: Int)
    func removeImage(image: UIImage)
}

struct SelectionTimer {
    var title: String!
    var timer: Int!
}

class SelectionHeader: UICollectionViewCell, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, TagListViewDelegate {
    
    @IBOutlet weak var tagField: TextField!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    //@IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var tagListScroll: UIScrollView!
    @IBOutlet weak var tagListGuide: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    
    private var submitNow: Bool = false
    private var blurView: UIVisualEffectView!
    private var cameraView: LLSimpleCamera!
    private var tags: [String: Bool] = [:]
    private var user = User.current()
    private var hashtag = ""
    private var arrowAnimation = CABasicAnimation(keyPath: "transform")
    private var timer: SelectionTimer!
    private var timerIndex: Int!
    private var timers: [SelectionTimer] = [
        SelectionTimer(title: "1 day", timer: 1),
        SelectionTimer(title: "2 days", timer: 2),
        SelectionTimer(title: "3 days", timer: 3),
        SelectionTimer(title: "4 days", timer: 4),
        SelectionTimer(title: "5 days", timer: 5),
        SelectionTimer(title: "6 days", timer: 6),
        SelectionTimer(title: "7 days", timer: 7)
    ]
    
    var delegate: SelectionHeaderDelegate!
    var images: NSMutableArray = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.blackColor()
        
        self.cameraView = LLSimpleCamera(quality: AVCaptureSessionPresetPhoto, position: LLCameraPositionRear, videoEnabled: false)
        self.cameraView.tapToFocus = true
        self.cameraView.view.frame = self.bounds
        self.insertSubview(self.cameraView.view, atIndex: 0)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.cameraView.start()
        }
        
        self.photoButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.photoButton.layer.borderWidth = 6
        self.photoButton.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.photoButton.layer.shadowOpacity = 0.8
        self.photoButton.layer.shadowRadius = 0
        self.photoButton.layer.shadowOffset = CGSizeMake(0, 3)
        self.photoButton.layer.cornerRadius = self.photoButton.frame.width/2
        self.photoButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        let switchCamera = UILongPressGestureRecognizer(target: self, action: Selector("switchCamera:"))
        switchCamera.minimumPressDuration = 0.25
        self.photoButton.addGestureRecognizer(switchCamera)
        
        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.blurView.alpha = 0
        self.cameraView.view.addSubview(self.blurView)
        
        self.tagLabel.textColor = UIColor(white: 1, alpha: 0.6)
        self.tagLabel.shadowColor = UIColor(white: 0, alpha: 0.25)
        self.tagLabel.shadowOffset = CGSizeMake(0, 1)
        
        self.tagField.tintColor = UIColor(white: 1, alpha: 1)
        self.tagField.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.tagField.layer.shadowOffset = CGSizeMake(0, 2)
        self.tagField.layer.shadowOpacity = 1
        self.tagField.layer.shadowRadius = 0
        self.tagField.font = UIFont(name: "Bariol-Bold", size: 36)
        self.tagField.delegate = self
        self.tagField.attributedPlaceholder = NSAttributedString(string: "#this", attributes: [
            NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6)
        ])
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
        
//        self.timerButton.contentHorizontalAlignment = .Left
//        self.timerButton.layer.shadowColor = UIColor.blackColor().CGColor
//        self.timerButton.layer.shadowOffset = CGSizeMake(-1, 1)
//        self.timerButton.layer.shadowOpacity = 0.1
//        self.timerButton.layer.shadowRadius = 0
//        self.timerImage.tintColor = UIColor.whiteColor()
//        self.timerImage.layer.shadowOffset = CGSizeMake(-1, 1)
//        self.timerImage.layer.shadowOpacity = 0.1
//        self.timerImage.layer.shadowRadius = 0
        
        self.tagList.backgroundColor = UIColor.clearColor()
        self.tagList.borderWidth = 1
        self.tagList.borderColor = UIColor(white: 0, alpha: 0.10)
        self.tagList.tagBackgroundColor = UIColor(white: 0, alpha: 0.15)
        self.tagList.textColor = UIColor.whiteColor()
        self.tagList.delegate = self
        self.tagList.cornerRadius = 15
        self.tagList.textFont = UIFont(name: "Bariol-Bold", size: 20)!
        self.tagList.marginX = 8
        self.tagList.marginY = 10
        self.tagList.paddingX = 10
        self.tagList.paddingY = 8
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("hideList:"))
        self.tagListScroll.addGestureRecognizer(tap)
        self.tagListScroll.hidden = true
        
        self.tagListGuide.textColor = UIColor(white: 1, alpha: 0.3)
        self.tagListGuide.shadowColor = UIColor.blackColor()
        self.tagListGuide.shadowOffset = CGSizeMake(0, 2)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        self.collectionView.registerClass(SelectionHeaderCell.self, forCellWithReuseIdentifier: "cell")
        
        self.reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cameraView.view.frame = self.bounds
        self.blurView.frame = self.bounds
    }
    
    func fetchTags() {
        var count = 0
        
        Tag.nearby { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
            
            count += tags.count
            self.tagListGuide.hidden = count > 0
        }
        
        Tag.friends(self.user) { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
            
            count += tags.count
            self.tagListGuide.hidden = count > 0
        }
        
        self.user.following { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
            
            count += tags.count
            self.tagListGuide.hidden = count > 0
        }
    }
    
    func flash() {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.whiteColor()
        self.addSubview(view)
        
        Globals.delay(0.2) { () -> () in
            view.removeFromSuperview()
        }
    }
    
    func switchCamera(gesture: UIGestureRecognizer) {
        guard gesture.state == UIGestureRecognizerState.Began else {
            return
        }
        
        self.cameraView.togglePosition()
        self.captureExit(self.photoButton)
    }
    
    @IBAction func captureImage(sender: UIButton) {
        self.captureExit(self.photoButton)
        
        self.cameraView.capture ({ (camera: LLSimpleCamera!, image: UIImage!, metaInfo:[NSObject : AnyObject]!, error: NSError!) -> Void in
            self.cameraView.start()
            
            if image != nil && error == nil {
                self.images.insertObject(image, atIndex: 0)
                self.updateCollection()
            } else {
                UIAlertView(title: "Aww Snap!", message: "Sorry! We failed to take the picture.", delegate: nil, cancelButtonTitle: "Try Again").show()
            }
        }, exactSeenImage: true)
        
        self.flash()
    }
    
    @IBAction func captureDown(sender: UIButton) {
        self.photoButton.layer.borderColor = UIColor(red:1, green:0.88, blue:0.2, alpha:1).CGColor
        self.photoButton.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.2)
    }
    
    @IBAction func captureExit(sender: UIButton) {
        self.photoButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.photoButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
//    @IBAction func changeTimer(sender: AnyObject) {
//        self.setTimer(self.timerIndex + 1)
//    }
    
    @IBAction func tagChanged(sender: AnyObject) {
        let alphaNumberSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        
        if var text = self.tagField.text {
            text = text.stringByReplacingOccurrencesOfString(" ", withString: "",
                options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            guard !text.isEmpty else {
                self.tagField.text = ""
                return
            }
            
            text = "#" + text.lowercaseString
                .componentsSeparatedByCharactersInSet(alphaNumberSet)
                .joinWithSeparator("")
            
            self.tagField.text = text
            self.hashtag = text
            self.checkArrow()
        }
    }

    @IBAction func uploadPhotos(sender: AnyObject) {
        let hashtag = String(self.hashtag.characters.dropFirst())
        
        guard !hashtag.isEmpty else {
            self.submitNow = true
            self.toggleTagList(true)
            return
        }
        
        self.delegate.updateTags(Array(self.images) as! [UIImage], hashtag: hashtag, timer: self.timer.timer)
    }
    
    @IBAction func goToFollowing(sender: AnyObject) {
        Globals.pagesController.setActiveController(2, direction: .Forward)
        Globals.mixpanel.track("Mobile.Selection.Go To Tags")
    }

    @IBAction func goToSettings(sender: AnyObject) {
        Globals.pagesController.setActiveController(0, direction: .Reverse)
        Globals.mixpanel.track("Mobile.Selection.Go To Settings")
    }
    
    func hideList(gesture: UITapGestureRecognizer) {
        self.tagField.resignFirstResponder()
    }
    
    func toggleTagList(show: Bool, animate: Bool = true) {
        let alpha: CGFloat = show ? 0 : 1
        
        guard show == self.tagListScroll.hidden else {
            return
        }
        
        if show {
            self.fetchTags()
        } else if self.submitNow {
            self.submitNow = false
            self.uploadPhotos(self)
        }
        
        UIView.animateWithDuration(animate ? 0.25 : 0, animations: { () -> Void in
//            self.timerImage.alpha = alpha
//            self.timerButton.alpha = alpha
            self.collectionView.alpha = alpha
            self.arrowButton.alpha = alpha
            self.photoButton.alpha = alpha
            self.tagListScroll.alpha = 1 - alpha
            self.blurView.alpha = 1 - alpha
            self.cameraView.view.alpha = show ? 0.5 : 1
        }) { (success) -> Void in
            self.tagListScroll.hidden = !show
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(self)
        self.toggleTagList(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.hashtag == "#" {
            self.setHashtag("")
        }
        
        self.toggleTagList(false)
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        self.setHashtag(title)
        self.toggleTagList(false)
        self.tagField.resignFirstResponder()
    }
    
    func setHashtag(tag: String) {
        self.hashtag = tag
        self.tagField.text = tag
    }
    
    func reset() {
        self.images.removeAllObjects()
        self.updateCollection()
        self.setHashtag("")
        self.setTimer(self.timers.count-1)
        self.toggleTagList(false, animate: false)
    }
    
    func setTimer(var index: Int) {
        if index >= self.timers.count {
            index = 0
        }
        
        self.timer = self.timers[index]
        self.timerIndex = index
        //self.timerButton.setTitle(self.timer.title, forState: .Normal)
        
        Globals.mixpanel.track("Mobile.Selection.Tag.Timer Changed", properties: [
            "days": self.timer.timer,
            "title": self.timer.title
        ])
    }
    
    func updateCollection() {
        self.collectionView.reloadData()
        
        self.collectionView.hidden = self.images.count == 0
        self.checkArrow()
        self.collectionView.flashScrollIndicators()
    }
    
    func checkArrow() {
        let enabled = self.images.count > 0
        
        if enabled != self.arrowButton.enabled {
            self.arrowButton.enabled = enabled
            self.arrowButton.layer.removeAnimationForKey("scaleAnimation")
            
            if enabled {
                self.arrowButton.layer.addAnimation(self.arrowAnimation, forKey: "scaleAnimation")
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.collectionView.frame.size.height - 10
        return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SelectionHeaderCell
        
        cell.imageView.image = self.images[indexPath.row] as? UIImage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = self.images[indexPath.row] as! UIImage
        self.images.removeObjectAtIndex(indexPath.row)
        self.delegate.removeImage(image)
        self.updateCollection()
    }
}

class TextField: UITextField {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        UIMenuController.sharedMenuController().menuVisible = false
        return false
    }
    
}
