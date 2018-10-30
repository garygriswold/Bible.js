//
//  ReaderPageController.swift
//  Settings
//
//  Created by Gary Griswold on 10/29/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class ReaderPagesController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var toolBar: ReaderToolbar!
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBar = ReaderToolbar(controller: self)
        
        self.dataSource = self
        self.delegate = self
        
        let page1 = ReaderViewController()
        let page2 = ReaderViewController()
        let page3 = ReaderViewController()
        
        self.setViewControllers([page1],// page2, page3],
                           direction: .reverse, //UIPageViewController.NavigationDirection,
                           animated: true,
                           completion: nil )//((Bool) -> Void)? = nil)
        
        // set gesture recognizers here as well
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = HistoryModel.shared.current()
        self.loadBiblePage(reference: ref)
    }
    
    func loadBiblePage(reference: Reference) {
        self.toolBar.loadBiblePage(reference: reference)
    }
    
    //
    // DataSource
    //
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 1
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    //
    // Delegate
    //
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        print("willTransitionTo called")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        print("transition completed called")
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        print("supported interface orientations called")
        return UIInterfaceOrientationMask.portrait
    }
    
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        print("preferred interface orientations called")
        return UIInterfaceOrientation.portrait
    }
}
