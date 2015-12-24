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
    func backTriggred()
    func shareTriggered()
}

class ShareHeaderController: UIViewController, UISearchBarDelegate {

    var tag: Tag!
    var backText: String!
    var delegate: ShareHeaderControllerDelegate!
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.red
        self.stepLabel.textColor = UIColor(white: 0, alpha: 0.5)
        self.headerLabel.textColor = UIColor.whiteColor()
        self.headerLabel.text = "Invite your friends\nto post to #\(self.tag.name)"
        
        self.backButton.setTitle(self.backText, forState: .Normal)
        
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
    }
    
    @IBAction func backTriggered(sender: AnyObject) {
        self.delegate.backTriggred()
    }
    
    @IBAction func nextTriggered(sender: AnyObject) {
        self.delegate.shareTriggered()
    }
    
    func updateNextButtonTitle(selection: Bool) {
        self.nextButton.setTitle(selection ? "SHARE" : "SKIP", forState: .Normal)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate.filterBySearch(self.searchBar.text!)
    }
    
}
