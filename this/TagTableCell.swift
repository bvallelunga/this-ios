//
//  TagTableCell.swift
//  this
//
//  Created by Brian Vallelunga on 1/23/16.
//  Copyright © 2016 Brian Vallelunga. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TagTableCell: UITableViewCell, TTTAttributedLabelDelegate {

    @IBOutlet weak var label: TTTAttributedLabel!
    
    static let linkAttrs: [NSObject: AnyObject] = [
        kCTForegroundColorAttributeName: UIColor(red:0.31, green:0.58, blue:1, alpha:1),
        NSFontAttributeName: UIFont(name: "Bariol", size: 20)!,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
    ]
    static let userAttrs: [NSObject: AnyObject] = [
        kCTForegroundColorAttributeName: Colors.greyBlue,
        NSFontAttributeName: UIFont(name: "Bariol-Bold", size: 20)!,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue
    ]
    
    override func awakeFromNib() {
        self.label.delegate = self
        self.label.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.label.linkAttributes = TagTableCell.linkAttrs
        self.label.activeLinkAttributes = TagTableCell.linkAttrs
        self.label.inactiveLinkAttributes = TagTableCell.linkAttrs
        self.label.numberOfLines = 0
        self.label.font = UIFont(name: "Bariol", size: 20)
        self.label.textColor = UIColor.blackColor()
        self.label.lineBreakMode = .ByWordWrapping
    }
    
    func updateComment(comment: Comment) {
        let url = "this://\(comment.user.objectId!)"
        let text = "\(comment.from) \(comment.message)"
        let range = NSString(string: text).rangeOfString(comment.from)
        let link = TTTAttributedLabelLink(attributes: TagTableCell.userAttrs,
            activeAttributes: TagTableCell.userAttrs, inactiveAttributes: TagTableCell.userAttrs,
            textCheckingResult: NSTextCheckingResult.linkCheckingResultWithRange(range, URL: NSURL(string: url)!))
        
        self.label.setText(text)
        self.label.addLink(link)
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.scheme == "this" {
            let controller = Globals.storyboard.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
            controller.user = User(withoutDataWithObjectId: url.host)
            Globals.tagController.navigationController?.pushViewController(controller, animated: true)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }

}
