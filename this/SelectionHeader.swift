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

protocol SelectionHeaderDelegate {
    func updateTags(hashtag: String, timer: Int)
}

struct SelectionTimer {
    var title: String!
    var timer: Int!
}

class SelectionHeader: UICollectionViewCell, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, TagListViewDelegate {
    
    @IBOutlet weak var placeholderView: FLAnimatedImageView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var tagField: TextField!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var tagListScroll: UIScrollView!
    
    private var tags: [String: Bool] = [:]
    private var user = User.current()
    private var gifURL: String! = ""
    private var hashtag: String = ""
    private var arrowAnimation = CABasicAnimation(keyPath: "transform")
    private var timer: SelectionTimer!
    private var timerIndex: Int!
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
        
        let path = NSBundle.mainBundle().URLForResource("Placeholder", withExtension: "gif")!
        let image = FLAnimatedImage(animatedGIFData: NSData(contentsOfURL: path.absoluteURL))
        
        self.placeholderView.layer.cornerRadius = 4
        self.placeholderView.clipsToBounds = true
        self.placeholderView.contentMode = .ScaleAspectFill
        self.placeholderView.animatedImage = image
        
        self.tagField.tintColor = UIColor(white: 0, alpha: 0.25)
        self.tagField.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.tagField.layer.shadowOffset = CGSizeMake(0, 2)
        self.tagField.layer.shadowOpacity = 1
        self.tagField.layer.shadowRadius = 0
        self.tagField.font = UIFont(name: "Bariol-Bold", size: 36)
        self.tagField.delegate = self
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
        self.timerImage.layer.shadowOffset = CGSizeMake(-1, 1)
        self.timerImage.layer.shadowOpacity = 0.1
        self.timerImage.layer.shadowRadius = 0
        
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
        self.tagListScroll.hidden = true
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        self.collectionView.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: "cell")
        
        self.reset()
        
        Globals.delay(60) { () -> () in
            self.updateHeaderGif()
        }
    }
    
    func fetchTags() {        
        Tag.nearby { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
        }
        
        Tag.friends(self.user) { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
        }
        
        self.user.following { (tags) -> Void in
            for tag in tags {
                if self.tags[tag.hashtag] == nil {
                    self.tagList.addTag(tag.hashtag)
                    self.tags[tag.hashtag] = true
                }
            }
        }
    }
    
    func updateHeaderGif() {
        Config.sharedInstance { (config) -> Void in
            guard let urlString = config.headerGif.url else {
                return
            }
            
            guard urlString != self.gifURL else {
                return
            }
            
            guard let url = NSURL(string: urlString) else {
                return
            }
            
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url), queue: NSOperationQueue(),
                completionHandler: { (response, data, error) -> Void in
                guard error == nil else {
                    return
                }
                
                Globals.delay(0, closure: { () -> () in
                    self.placeholderView.animatedImage = FLAnimatedImage(animatedGIFData: data)
                    self.gifURL = urlString
                })
            })
        }
    }
    
    @IBAction func changeTimer(sender: AnyObject) {
        self.setTimer(self.timerIndex + 1)
    }
    
    @IBAction func tagChanged(sender: AnyObject) {
        let alphaNumberSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        
        if var text = self.tagField.text {
            text = text.stringByReplacingOccurrencesOfString(" ", withString: "",
                options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            guard !text.isEmpty else {
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
        self.delegate.updateTags(hashtag, timer: self.timer.timer)
    }
    
    @IBAction func goToFollowing(sender: AnyObject) {
        Globals.pagesController.setActiveController(2, direction: .Forward)
        Globals.mixpanel.track("Mobile.Selection.Go To Tags")
    }

    @IBAction func goToSettings(sender: AnyObject) {
        Globals.pagesController.setActiveController(0, direction: .Reverse)
        Globals.mixpanel.track("Mobile.Selection.Go To Settings")
    }
    
    func toggleTagList(show: Bool, animate: Bool = true) {
        let alpha: CGFloat = show ? 0 : 1
        
        guard show == self.tagListScroll.hidden else {
            return
        }
        
        if show {
            self.fetchTags()
        }
        
        UIView.animateWithDuration(animate ? 0.25 : 0, animations: { () -> Void in
            self.placeholderView.alpha = alpha
            self.placeholderLabel.alpha = alpha
            self.timerImage.alpha = alpha
            self.timerButton.alpha = alpha
            self.collectionView.alpha = alpha
            self.arrowButton.alpha = alpha
            self.tagListScroll.alpha = 1 - alpha
        }) { (success) -> Void in
            self.tagListScroll.hidden = !show
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(self)
        self.toggleTagList(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
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
        self.imagesSelected([])
        self.setHashtag("")
        self.setTimer(2)
        self.toggleTagList(true, animate: false)
    }
    
    func setTimer(var index: Int) {
        if index >= self.timers.count {
            index = 0
        }
        
        self.timer = self.timers[index]
        self.timerIndex = index
        self.timerButton.setTitle(self.timer.title, forState: .Normal)
        
        Globals.mixpanel.track("Mobile.Selection.Tag.Timer Changed", properties: [
            "days": self.timer.timer,
            "title": self.timer.title
        ])
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
        let tagLength = NSString(string: self.hashtag).length
        let enabled = !self.images.isEmpty && tagLength > 1
        
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

class TextField: UITextField {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        UIMenuController.sharedMenuController().menuVisible = false
        return false
    }
    
}
