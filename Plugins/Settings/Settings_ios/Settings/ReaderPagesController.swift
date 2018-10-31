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
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBar = ReaderToolbar(controller: self)
        
        self.dataSource = self
        self.delegate = self
        
        // set gesture recognizers here as well
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.backgroundColor = .white
        if let pageControl = self.view.subviews[1] as? UIPageControl {
            pageControl.pageIndicatorTintColor = .lightGray
            pageControl.currentPageIndicatorTintColor = .black
            pageControl.layer.borderWidth = 0.4
            pageControl.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        }
    }
    
    func loadBiblePage(reference: Reference) {
        self.toolBar.loadBiblePage(reference: reference)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isToolbarHidden = false
        
        let ref = HistoryModel.shared.current()
        self.loadBiblePage(reference: ref)
        
        let page1 = ReaderViewController()
        page1.reference = HistoryModel.shared.current()
        
        self.setViewControllers([page1],
                                direction: .forward,
                                animated: true,
                                completion: nil )//((Bool) -> Void)? = nil)
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
        return self.presentPage(controller: viewController, next: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("presentation After controller called")
        return self.presentPage(controller: viewController, next: true)
    }
    
    private func presentPage(controller: UIViewController, next: Bool) -> UIViewController? {
        if let page = controller as? ReaderViewController {
            let reference = page.reference!
            var another: Reference
            if next {
                another = reference.bible.tableContents!.nextChapter(reference: reference)
            } else {
                another = reference.bible.tableContents!.priorChapter(reference: reference)
            }
            let reader = ReaderViewController()
            reader.reference = another
            return reader
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("presentation count called")
        //return references.count
        return 4
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
