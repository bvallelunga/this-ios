//
//  TagHeaderController.swift
//  this
//
//  Created by Brian Vallelunga on 12/18/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class TagHeaderController: UIViewController {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.darkGrey
        
        self.setupButton(self.followingButton, color: Colors.blue)
        self.setupButton(self.inviteButton, color: Colors.green)
        self.downloadButton.tintColor = UIColor.whiteColor()
    }
    
    func setupButton(button: UIButton, color: UIColor) {
        button.tintColor = UIColor.whiteColor()
        button.backgroundColor = color
        button.layer.cornerRadius = 3
    }

}
