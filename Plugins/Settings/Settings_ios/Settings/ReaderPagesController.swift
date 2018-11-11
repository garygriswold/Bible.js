//
//  ReaderPageController.swift
//  Settings
//
//  Created by Gary Griswold on 10/29/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class ReaderPagesController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    static let WEB_LOAD_DONE = NSNotification.Name("web-load-done")
    
    private var readerViewQueue: ReaderViewQueue
    private var toolBar: ReaderToolbar!

    init() {
        self.readerViewQueue = ReaderViewQueue()
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        self.readerViewQueue = ReaderViewQueue()
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
        
        let page1 = self.readerViewQueue.first(reference: reference)
        self.setViewControllers([page1], direction: .forward, animated: true, completion: nil)
        // listen for completion of webView set with content in ReaderViewController
        NotificationCenter.default.addObserver(self, selector: #selector(setViewControllerComplete),
                                               name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
    
    @objc func setViewControllerComplete(note: NSNotification) {
        //NotificationCenter.default.removeObserver(self, name: ReaderPagesController.WEB_LOAD_DONE,
        //                                          object: nil)
        self.readerViewQueue.preload(controller: self.viewControllers![0])
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
        return self.readerViewQueue.prior(controller: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.readerViewQueue.next(controller: viewController)
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
        //let page = pendingViewControllers[0] as! ReaderViewController
        //print("will Transition To \(page.reference.toString())")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let page = self.viewControllers![0] as! ReaderViewController
        print("Display \(page.reference.toString())")
        self.toolBar.loadBiblePage(reference: page.reference)
        HistoryModel.shared.changeReference(reference: page.reference)
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
