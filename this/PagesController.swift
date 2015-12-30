//
//  PagesController.swift
//  this
//
//  Created by Brian Vallelunga on 12/12/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class PagesController: UIPageViewController, UIAlertViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    // MARK: Instance Variables
    var controllers = Dictionary<Int, PageController>()
    var currentPage = -1
    private var startPage = 1
    private let pages = 3
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    private var scrollView: UIScrollView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Global
        Globals.pagesController = self
        
        // Create Page View Controller
        self.view.backgroundColor = UIColor.clearColor()
        self.dataSource = self
        self.delegate = self
        
        for controller in self.view.subviews {
            if let scrollView = controller as? UIScrollView {
                self.scrollView = scrollView
                self.scrollView.delegate = self
            }
        }
        
        // Create Controllers
        for index in 0...self.pages {
            var page: PageController!
            
            switch(index) {
                case 0: page = self.storyBoard.instantiateViewControllerWithIdentifier("SettingsController") as? PageController
                case 1: page = self.storyBoard.instantiateViewControllerWithIdentifier("SelectionController") as? PageController
                default: page = self.storyBoard.instantiateViewControllerWithIdentifier("TagsController") as? PageController
            }
            
            page?.view.frame = self.view.frame
            page?.pageIndex = index
            self.controllers[index] = page
        }
        
        self.didMoveToParentViewController(self)
        
        // Remove Text From Back Button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000),
            forBarMetrics: UIBarMetrics.Default)
        
        // Set Start Page
        self.setActiveController(self.startPage, animated: false, direction: .Forward)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Instance Methods
    func lockPageView() {
        self.scrollView?.scrollEnabled = false
    }
    
    func unlockPageView() {
        self.scrollView?.scrollEnabled = true
    }
    
    func setActiveController(index: Int, animated: Bool = true, direction: UIPageViewControllerNavigationDirection, callback: (() -> Void)! = nil) {
        let controller = self.viewControllerAtIndex(index)
        
        self.unlockPageView()
        
        if self.currentPage == index && controller != nil {
            callback?()
            return
        }
        
        self.setViewControllers([
            self.viewControllerAtIndex(index)
        ], direction: direction, animated: animated, completion: { (success: Bool) -> Void in
                self.currentPage = index
                callback?()
        })
    }
    
    func viewControllerAtIndex(index: Int) -> PageController! {
        if self.pages == 0 || index >= self.pages {
            return nil
        }
        
        return self.controllers[index]
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            self.currentPage = (self.viewControllers!.last as! PageController).pageIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! PageController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! PageController).pageIndex
        
        if index == NSNotFound || index >= self.pages {
            return nil
        }
        
        return self.viewControllerAtIndex(index + 1)
    }
    
    // MARK: UIScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        } else if self.currentPage == (self.pages - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        } else if self.currentPage == (self.pages - 1) && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            targetContentOffset.memory.x = scrollView.bounds.size.width
            targetContentOffset.memory.y = 0
        }
    }
}
