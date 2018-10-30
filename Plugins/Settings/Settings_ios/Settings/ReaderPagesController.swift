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
    private var page1: ReaderViewController!
    private var page2: ReaderViewController!
    private var page3: ReaderViewController!

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
        
        self.page1 = ReaderViewController()
        self.page2 = ReaderViewController()
        self.page2.loadBiblePage(reference: HistoryModel.shared.current())
        self.page3 = ReaderViewController()
        
        self.setViewControllers([page2],// page2, page3],
                           direction: .forward, //UIPageViewController.NavigationDirection,
                           animated: true,
                           completion: nil )//((Bool) -> Void)? = nil)
        
        // set gesture recognizers here as well
        
        
    }
    
    func loadBiblePage(reference: Reference) {
        self.toolBar.loadBiblePage(reference: reference)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = HistoryModel.shared.current()
        self.loadBiblePage(reference: ref)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isToolbarHidden = true
    }
    //
    // DataSource
    //
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("presentation Before controller called")
        page1.loadBiblePage(reference: HistoryModel.shared.current())
        return self.page1
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("presentation After controller called")
        page3.loadBiblePage(reference: HistoryModel.shared.current())
        return self.page3
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("presentation count called")
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        print("presentation Index called")
        return 1
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
