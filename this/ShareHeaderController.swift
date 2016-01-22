//
//  ShareHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

protocol ShareHeaderControllerDelegate {
    func filterBySearch(text: String)
    func shareTriggered()
    func backTriggered()
}

class ShareHeaderController: UIViewController, UISearchBarDelegate {

    var tag: Tag!
    var backText: String!
    var delegate: ShareHeaderControllerDelegate!
    static var text = NSAttributedString(string: "Invite your friends\nto post to ")
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.red
        self.stepLabel.textColor = UIColor(white: 0, alpha: 0.5)
        self.headerLabel.textColor = UIColor.whiteColor()
        self.nextButton.setTitleColor(UIColor(white: 1, alpha: 0.5), forState: .Disabled)
        
        let tagString = NSMutableAttributedString(string: self.tag.hashtag, attributes: [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ])
        
        tagString.insertAttributedString(ShareHeaderController.text, atIndex: 0)
        
        self.headerLabel.attributedText = tagString
        
        // Configure Search Bar
        self.searchBar.delegate = self
        
        for subview in self.searchBar.subviews {
            for subSubView in subview.subviews {
                if subSubView.conformsToProtocol(UITextInputTraits) {
                    let textField = subSubView as! UITextField
                    textField.returnKeyType = UIReturnKeyType.Done
                    textField.enablesReturnKeyAutomatically = false
                }
            }
        }
        
        self.backButton.setTitle(self.backText, forState: .Normal)
    }
    
    @IBAction func backTriggered(sender: AnyObject) {
        self.delegate.backTriggered()
    }
    
    @IBAction func nextTriggered(sender: AnyObject) {
        self.delegate.shareTriggered()
    }
    
    func updateNextButtonTitle(selection: Bool) {
        self.nextButton.enabled = selection
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate.filterBySearch(self.searchBar.text!)
    }
    
}
