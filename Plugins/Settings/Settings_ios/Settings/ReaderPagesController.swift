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
    
    override var prefersStatusBarHidden: Bool { get { return true } }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = AppFont.backgroundColor
        self.toolBar = ReaderToolbar(controller: self)
        
        self.dataSource = self
        self.delegate = self
        
        // set gesture recognizers here as well
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let pageControl = self.view.subviews[1] as? UIPageControl {
            pageControl.backgroundColor = AppFont.backgroundColor
            pageControl.pageIndicatorTintColor = .lightGray
            pageControl.currentPageIndicatorTintColor = AppFont.nightMode ? .white : .black
            
            let layer = CALayer()
            layer.borderColor = UIColor.lightGray.cgColor
            layer.borderWidth = 0.3
            layer.frame = CGRect(x: 0, y: 0, width: pageControl.frame.width, height: 0.3)
            pageControl.layer.addSublayer(layer)
        }
        self.toolBar.refresh()
    }
    
    func loadBiblePage(reference: Reference) {
        self.toolBar.loadBiblePage(reference: reference)
        
        let page1 = ReaderViewController()
        page1.reference = reference
        page1.which = .this
        
        self.setViewControllers([page1], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //let hideNavBar = (AppFont.nightMode) ? false : true
        let hideNavBar = true
        self.navigationController?.setNavigationBarHidden(hideNavBar, animated: false)
        self.navigationController?.isToolbarHidden = false
        
        self.loadBiblePage(reference: HistoryModel.shared.current())
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
        return self.presentPage(controller: viewController, which: .prior)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.presentPage(controller: viewController, which: .next)
    }
    
    private func presentPage(controller: UIViewController, which: GetChapter) -> UIViewController? {
        if let page = controller as? ReaderViewController {
            let reader = ReaderViewController()
            reader.reference = page.reference!
            reader.which = which
            return reader
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("presentation count called")
        return 7
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
        print("willTransitionTo called \(pendingViewControllers.count)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let page = self.viewControllers as? [ReaderViewController] {
            self.toolBar.loadBiblePage(reference: page[0].reference)
            HistoryModel.shared.changeReference(reference: page[0].reference)
        }
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
